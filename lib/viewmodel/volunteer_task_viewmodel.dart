import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../model/volunteer_task_model.dart';
import '../repo/volunteer_task_repo.dart';

class VolunteerTaskViewModel extends ChangeNotifier {
  final VolunteerTaskRepo repo;
  VolunteerTaskViewModel({required this.repo});

  List<VolunteerTaskModel> tasks = [];
  bool loading = false;
  String? errorMessage;
  String? actingOnTaskId;
  StreamSubscription? subscription;
  String? _currentVolunteerId;

  void listenFor(String volunteerId) {
    if (_currentVolunteerId == volunteerId) return;
    _currentVolunteerId = volunteerId;
    subscription?.cancel();
    loading = true;
    notifyListeners();
    subscription = repo.getVolunteerTasks(volunteerId).listen((data) {
      tasks = data;
      loading = false;
      errorMessage = null;
      notifyListeners();
    }, onError: (error) {
      loading = false;
      errorMessage = error.toString();
      notifyListeners();
    });
  }

  List<VolunteerTaskModel> get pendingTasks {
    final list = tasks.where((task) => task.status.toLowerCase() == "pending").toList();
    list.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
    return list;
  }

  List<VolunteerTaskModel> get activeTasks {
    final list = tasks.where((task) {
      final status = task.status.toLowerCase();
      return status == "accepted" || status == "in_progress" || status == "inprogress" || status == "reached";
    }).toList();

    int stageRank(String status) {
      switch (status.toLowerCase().replaceAll('_', '')) {
        case 'inprogress':
          return 0;
        case 'accepted':
          return 1;
        case 'reached':
          return 2;
        default:
          return 3;
      }
    }
    list.sort((a, b) {
      final stageCompare = stageRank(a.status).compareTo(stageRank(b.status));
      if (stageCompare != 0) return stageCompare;
      // Same stage: newest first
      return (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0));
    });

    return list;
  }

  List<VolunteerTaskModel> get pastTasks {
    final list = tasks.where((task) {
      final status = task.status.toLowerCase();
      return status == "completed" || status == "rejected";
    }).toList();
    list.sort((a, b) => (b.respondedAt ?? b.createdAt ?? DateTime(0))
        .compareTo(a.respondedAt ?? a.createdAt ?? DateTime(0)));
    return list;
  }

  Future<void> updateStatus(String taskId, String status) async {
    try {
      actingOnTaskId = taskId;
      notifyListeners();
      await repo.updateTaskStatus(taskId, status);
    } finally {
      actingOnTaskId = null;
      notifyListeners();
    }
  }


  Future<void> _captureLocation(String taskId) async {
    try {
      debugPrint(" Starting location capture for $taskId");

      var permission = await Geolocator.checkPermission();
      debugPrint("Permission status: $permission");

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint(" Permission after request: $permission");
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          debugPrint(" STOPPED: permission denied");
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        debugPrint(" STOPPED: permission denied forever");
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint(" Location service enabled: $serviceEnabled");
      if (!serviceEnabled) {
        debugPrint(" STOPPED: location services disabled");
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      debugPrint("Got position: ${position.latitude}, ${position.longitude}");

      await repo.updateTaskLocation(taskId, position.latitude, position.longitude);
      debugPrint(" SUCCESS: wrote location to Firestore for $taskId");
    } catch (e) {
      debugPrint(" LOCATION CAPTURE FAILED for task $taskId: $e");
    }
  }

  Future<void> accept(String id) async {
    await updateStatus(id, "accepted");
    await _captureLocation(id);
  }

  Future<void> reject(String id) async {
    await updateStatus(id, "rejected");
  }

  Future<void> startDelivery(String id) async {
    await updateStatus(id, "InProgress");
    await _captureLocation(id);
  }

  Future<void> markReached(String id) async {
    await updateStatus(id, "reached");
    await _captureLocation(id);
  }

  Future<void> unaccept(String id) async {
    try {
      actingOnTaskId = id;
      notifyListeners();
      await repo.unacceptTask(id);
    } finally {
      actingOnTaskId = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }
}