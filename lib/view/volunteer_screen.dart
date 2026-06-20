import 'package:flutter/material.dart';

class VolunteerScreen extends StatelessWidget {
  const VolunteerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A5C2E),

      body: SafeArea(
        child: Column(
          children: [

            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
              color: const Color(0xFF3A5C2E),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      const Text(
                        "Volunteer Hub",
                        style: TextStyle(
                          color: Color(0xFFF5F0E8),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5F0E8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF3A5C2E),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Help deliver donations to people in need",
                    style: TextStyle(
                      color: Color(0xFFD4E8C2),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [

                      /// STATS
                      Row(
                        children: [

                          Expanded(
                            child: _statCard(
                              "24",
                              "Tasks\nCompleted",
                              Icons.check_circle_outline,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _statCard(
                              "3",
                              "Active\nTasks",
                              Icons.local_shipping_outlined,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _statCard(
                              "120",
                              "Items\nDelivered",
                              Icons.favorite_border,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// GOAL CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFD4E8C2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Text(
                              "Monthly Goal",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              "24 of 40 deliveries",
                            ),

                            const SizedBox(height: 12),

                            ClipRRect(
                              borderRadius:
                              BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: 0.60,
                                minHeight: 8,
                                backgroundColor:
                                Colors.grey.shade300,
                                valueColor:
                                const AlwaysStoppedAnimation(
                                  Color(0xFF3A5C2E),
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "60%",
                                style: TextStyle(
                                  color: Color(0xFF3A5C2E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// AVAILABLE TASKS HEADER
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [

                          const Text(
                            "Available Tasks",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "See all",
                              style: TextStyle(
                                color: Color(0xFF3A5C2E),
                              ),
                            ),
                          ),
                        ],
                      ),

                      /// TASKS
                      _taskCard(
                        title: "Winter Clothes",
                        pickup: "Jawalakhel",
                        dropoff: "Pulchowk",
                        distance: "1.2 km",
                      ),

                      _taskCard(
                        title: "Food Package",
                        pickup: "Baneshwor",
                        dropoff: "Maitidevi",
                        distance: "2.5 km",
                      ),

                      _taskCard(
                        title: "School Supplies",
                        pickup: "Lagankhel",
                        dropoff: "Kupondole",
                        distance: "0.8 km",
                      ),

                      const SizedBox(height: 20),

                      /// MY TASKS
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "My Active Tasks",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _myTaskCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _statCard(
      String value,
      String title,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4E8C2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Icon(
            icon,
            color: const Color(0xFF3A5C2E),
            size: 18,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2E0A),
            ),
          ),

          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _taskCard({
    required String title,
    required String pickup,
    required String dropoff,
    required String distance,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4E8C2),
        ),
      ),
      child: Row(
        children: [

          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F0DD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF3A5C2E),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "$pickup → $dropoff",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                Text(
                  distance,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor:
              const Color(0xFF3A5C2E),
            ),
            child: const Text(
              "Accept",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _myTaskCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4E8C2),
        ),
      ),
      child: Row(
        children: [

          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F0DD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_shipping,
              color: Color(0xFF3A5C2E),
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  "Winter Clothes",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  "Status: Assigned",
                  style: TextStyle(
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: null,
            child: Text("Picked Up"),
          ),
        ],
      ),
    );
  }
}