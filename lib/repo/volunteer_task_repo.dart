import '../model/volunteer_task_model.dart';


abstract class VolunteerTaskRepo {


  Stream<List<VolunteerTaskModel>> getVolunteerTasks(
      String volunteerId
      );


  Future<void> updateTaskStatus(
      String taskId,
      String status
      );


}