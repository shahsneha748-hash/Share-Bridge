// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:sharebridge/constants/colors.dart';
// import 'package:sharebridge/repo/dashboard_repo_impl.dart';
// import 'package:sharebridge/components/app_header.dart';
// import 'package:sharebridge/components/category_card.dart';
// import 'package:sharebridge/view/item_detail_screen.dart';
// import 'package:sharebridge/view/notification_screen.dart';
// import 'package:sharebridge/view/browse_screen.dart'; // <-- add BrowseScreen
// import 'package:sharebridge/viewmodel/notification_view_model.dart';
// import '../viewmodel/dashboard_view_model.dart';
//
// class DashboardScreenDemo extends StatefulWidget {
//   const DashboardScreenDemo({super.key, required String uid});
//
//   @override
//   State<DashboardScreenDemo> createState() => _DashboardScreenDemoState();
// }
//
// class _DashboardScreenDemoState extends State<DashboardScreenDemo> {
//   int _currentIndex = 0;
//
//   late final List<Widget> _screens = [
//     ChangeNotifierProvider(
//       create: (_) => DashboardViewModel(DashboardRepoImpl()),
//       child: _DashboardView(onGoToBrowse: ({String? category}) {
//         setState(() {
//           _currentIndex = 1; // switch to Browse tab
//         });
//       }),
//     ),
//     const BrowseScreen(),
//     const NotificationScreen(),
//     const Placeholder(), // Post tab placeholder
//     const Placeholder(), // Profile tab placeholder
//   ];
//
//   void _onNavTap(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: _onNavTap,
//         selectedItemColor: AppColors.darkGreen,
//         unselectedItemColor: Colors.grey,
//         type: BottomNavigationBarType.fixed,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.search), label: "Browse"),
//           BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
//           BottomNavigationBarItem(icon: Icon(Icons.add), label: "Post"),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Dashboard View ───────────────────────────────────────────────────────────
//
// class _DashboardView extends StatelessWidget {
//   final void Function({String? category})? onGoToBrowse;
//   const _DashboardView({this.onGoToBrowse});
//
//   void _showSnackbar(BuildContext context, String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: AppColors.darkGreen,
//         duration: const Duration(seconds: 1),
//       ),
//     );
//   }
//
//   void _goToBrowse(BuildContext context, {String? category}) {
//     if (onGoToBrowse != null) {
//       onGoToBrowse!(category: category);
//     } else {
//       _showSnackbar(context, 'Browse — Coming Soon');
//     }
//   }
//
//   void _openItemDetail(BuildContext context, Map<String, dynamic> item) {
//     final vm = context.read<DashboardViewModel>();
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
//     ).then((_) => vm.refresh());
//   }
//
//   Widget _notificationBell(BuildContext context) {
//     return Consumer<NotificationViewModel>(
//       builder: (context, vm, child) {
//         return GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const NotificationScreen()),
//             );
//             _showSnackbar(context, 'Notifications — Coming Soon');
//           },
//           child: Stack(
//             children: [
//               Container(
//                 width: 48,
//                 height: 48,
//                 decoration: const BoxDecoration(
//                   color: AppColors.cream,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.notifications, color: AppColors.darkGreen, size: 26),
//               ),
//               if (vm.unreadCount > 0)
//                 Positioned(
//                   right: 8,
//                   top: 8,
//                   child: Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: const BoxDecoration(
//                       color: Colors.redAccent,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Text(
//                       vm.unreadCount.toString(),
//                       style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final vm = context.watch<DashboardViewModel>();
//
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: const SystemUiOverlayStyle(
//         statusBarColor: AppColors.darkGreen,
//         statusBarIconBrightness: Brightness.light,
//       ),
//       child: Scaffold(
//         backgroundColor: AppColors.darkGreen,
//         body: SafeArea(
//           child: Column(
//             children: [
//               AppHeader(title: 'Share Bridge', trailing: _notificationBell(context)),
//               Expanded(
//                 child: Container(
//                   color: Colors.white,
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.only(bottom: 24),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 18),
//                         _SearchBar(onTap: () => _goToBrowse(context)),
//                         const SizedBox(height: 26),
//                         // Categories
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: CategoryCard(
//                                   icon: Icons.restaurant,
//                                   label: 'Food',
//                                   onTap: () => _goToBrowse(context, category: 'Food'),
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: CategoryCard(
//                                   icon: Icons.edit,
//                                   label: 'Stationery',
//                                   onTap: () => _goToBrowse(context, category: 'Stationery'),
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: CategoryCard(
//                                   icon: Icons.checkroom,
//                                   label: 'Clothes',
//                                   onTap: () => _goToBrowse(context, category: 'Clothes'),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ── Search Bar ────────────────────────────────────────────────────────────────
//
// class _SearchBar extends StatelessWidget {
//   final VoidCallback onTap;
//   const _SearchBar({required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           height: 48,
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: AppColors.inputBg,
//             borderRadius: BorderRadius.circular(30),
//             border: Border.all(color: Colors.grey.shade300, width: 1.2),
//           ),
//           child: const Row(
//             children: [
//               Icon(Icons.search, color: Colors.grey, size: 22),
//               SizedBox(width: 10),
//               Text('Search for donations...', style: TextStyle(color: Colors.grey, fontSize: 15)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
