// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../repo/request_system_repo.dart';
// import '../viewmodel/request_system_view_model.dart';
//
//
// class RequestSystemScreenDemo extends StatelessWidget {
//   const RequestSystemScreenDemo({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => RequestSystemViewModel(RequestSystemRepo()),
//       child: const _RequestView(),
//     );
//   }
// }
//
// class _RequestView extends StatelessWidget {
//   const _RequestView();
//
//   static const kHeader = Color(0xFF3A6B1E);
//   static const kInputBg = Color(0xFFD6E8D0);
//   static const kBorder = Color(0xFFB0CBA8);
//   static const kChipOn = Color(0xFFC2D9BB);
//   static const kCardBg = Color(0xFFF2F5F0);
//   static const kPageBg = Colors.white;
//   static const kText = Color(0xFF1A2A1A);
//   static const kSub = Color(0xFF5A7050);
//   static const kWhite = Colors.white;
//   static const kRed = Color(0xFFE74C3C);
//
//   Widget _section(Widget child) => Container(
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       color: kCardBg,
//       borderRadius: BorderRadius.circular(14),
//     ),
//     child: child,
//   );
//
//   Widget _chip(Map cat, String selected, VoidCallback onTap) {
//     final active = selected == cat['id'];
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: active ? kChipOn : kInputBg,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: kBorder),
//         ),
//         child: Row(mainAxisSize: MainAxisSize.min, children: [
//           Icon(cat['icon'], size: 16, color: kHeader),
//           const SizedBox(width: 6),
//           Text(cat['label'], style: const TextStyle(fontSize: 13)),
//         ]),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final vm = context.watch<RequestSystemViewModel>();
//
//     if (vm.submitted) {
//       return Scaffold(
//         body: Center(
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             const Icon(Icons.check_circle, size: 80, color: kHeader),
//             const SizedBox(height: 10),
//             const Text("Request Posted"),
//             ElevatedButton(
//               onPressed: vm.reset,
//               child: const Text("Create Another"),
//             )
//           ]),
//         ),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: kPageBg,
//       appBar: AppBar(
//         backgroundColor: kHeader,
//         title: const Text("Create Request"),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(14),
//         child: Column(children: [
//
//           _section(Column(children: [
//             TextField(controller: vm.nameController, decoration: const InputDecoration(hintText: "Name")),
//             TextField(controller: vm.titleController, decoration: const InputDecoration(hintText: "Title")),
//           ])),
//
//           const SizedBox(height: 12),
//
//           _section(TextField(
//             controller: vm.descriptionController,
//             maxLines: 3,
//             decoration: const InputDecoration(hintText: "Description"),
//           )),
//
//           const SizedBox(height: 12),
//
//           _section(TextField(
//             controller: vm.locationController,
//             decoration: const InputDecoration(hintText: "Location"),
//           )),
//
//           const SizedBox(height: 12),
//
//           _section(Wrap(
//             spacing: 10,
//             children: vm.categories
//                 .map((c) => _chip(c, vm.category,
//                     () => vm.setCategory(c['id'] as String)))
//                 .toList(),
//           )),
//
//           const SizedBox(height: 20),
//
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: kHeader),
//               onPressed: vm.canSubmit ? vm.submit : null,
//               child: vm.isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text("Post Request"),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }
// }