import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/colors.dart';
import '../viewmodel/block_view_model.dart';


class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() =>
      _BlockedUsersScreenState();
}


class _BlockedUsersScreenState extends State<BlockedUsersScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      context
          .read<BlockViewModel>()
          .fetchBlockedUsers(
        FirebaseAuth.instance.currentUser!.uid,
      );

    });
  }


  @override
  Widget build(BuildContext context) {

    final vm = context.watch<BlockViewModel>();

    return Scaffold(

      backgroundColor: AppColors.background,


      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: (){
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Blocked Users",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),



      body: vm.loading

          ? const Center(
        child: CircularProgressIndicator(),
      )


          : vm.blockedUsers.isEmpty

          ? _emptyState()


          : ListView.builder(

        padding:
        const EdgeInsets.all(16),

        itemCount:
        vm.blockedUsers.length,


        itemBuilder:(context,index){

          final user =
          vm.blockedUsers[index];


          return Container(

            margin:
            const EdgeInsets.only(bottom:12),


            padding:
            const EdgeInsets.all(14),


            decoration: BoxDecoration(

              color: AppColors.cardBg,

              borderRadius:
              BorderRadius.circular(16),

              border: Border.all(
                color: AppColors.borderLight,
              ),

            ),


            child: Row(

              children: [


                CircleAvatar(

                  radius:26,

                  backgroundImage:
                  user.profilePicture != null

                      ? NetworkImage(
                    user.profilePicture!,
                  )

                      : null,


                  child:
                  user.profilePicture == null

                      ? Text(
                    user.name[0]
                        .toUpperCase(),

                    style:
                    const TextStyle(
                      fontSize:20,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  )

                      : null,

                ),



                const SizedBox(width:14),



                Expanded(

                  child: Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children:[

                      Text(
                        user.name,

                        style:
                        const TextStyle(
                          fontSize:16,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),


                      const SizedBox(height:4),


                      const Text(
                        "Blocked user",

                        style:
                        TextStyle(
                          color:
                          AppColors.textMuted,
                          fontSize:13,
                        ),
                      ),

                    ],
                  ),
                ),



                OutlinedButton(

                  onPressed:(){

                    vm.unblockUser(
                      FirebaseAuth.instance.currentUser!.uid,
                      user.uid,
                    );

                  },


                  style:
                  OutlinedButton.styleFrom(

                    foregroundColor:
                    AppColors.primary,

                    side:
                    const BorderSide(
                      color:
                      AppColors.primary,
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(20),
                    ),

                  ),


                  child:
                  const Text(
                    "Unblock",
                  ),

                ),

              ],
            ),
          );

        },
      ),
    );
  }



  Widget _emptyState(){

    return Center(

      child: Column(

        mainAxisSize:
        MainAxisSize.min,


        children:[

          Icon(
            Icons.block_outlined,

            size:70,

            color:
            AppColors.textMuted,
          ),


          const SizedBox(height:16),


          const Text(
            "No blocked users",

            style:
            TextStyle(
              fontSize:18,
              fontWeight:
              FontWeight.w600,
            ),
          ),


          const SizedBox(height:6),


          const Text(
            "Users you block will appear here",

            style:
            TextStyle(
              color:
              AppColors.textMuted,
            ),
          ),

        ],
      ),
    );
  }
}