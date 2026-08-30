import 'package:flutter/material.dart';
import 'screens/water_report_screen.dart';
import 'screens/bills_screen.dart';
import 'screens/flow_rate_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';

class PortalDashboard extends StatefulWidget {
  const PortalDashboard({super.key});

  @override
  State<PortalDashboard> createState() => _PortalDashboardState();
}

class _PortalDashboardState extends State<PortalDashboard> {
    void logout() async {

    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
        builder: (context) => const LoginScreen(),
        ),
    );

    }

  int selectedIndex = 0;

  final List<String> menuItems = [
    "Water Report",
    "Monthly/Annual Bills",
    "Real-time Flow Rate"
  ];

  final List<Widget> pages = [
    const WaterReportScreen(),
    const BillsScreen(),
    const FlowRateScreen(),
    ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [

          /// 🔵 TOP HEADER
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [

                /// LEFT SIDE
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Water Meter Portal",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold),
                        ),
                        Text(
                          "Meter ID: WM001",
                          style: TextStyle(
                              color: Colors.blue),
                        )
                      ],
                    ),
                  ],
                ),

                /// RIGHT SIDE
                Row(
                  children: [

                    const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text("RK",
                          style: TextStyle(
                              color: Colors.white)),
                    ),

                    const SizedBox(width: 10),

                    const Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text("C. Tamizhselvan",
                            style: TextStyle(
                                fontWeight:
                                    FontWeight.bold)),
                        // Text("Aadhar Login",
                        //     style: TextStyle(
                        //         fontSize: 12,
                        //         color:
                        //             Colors.grey)),
                      ],
                    ),

                    const SizedBox(width: 20),

                    OutlinedButton.icon(
                        onPressed: logout,
                        icon: const Icon(Icons.logout),
                        label: const Text("Logout"),
                    ),
                  ],
                )
              ],
            ),
          ),

          /// 🔹 BODY
          Expanded(
            child: Row(
              children: [

                /// SIDEBAR
                Container(
                  width: 250,
                  color: Colors.white,
                  child: ListView.builder(
                    itemCount:
                        menuItems.length,
                    itemBuilder:
                        (context, index) {
                      return ListTile(
                        selected:
                            selectedIndex ==
                                index,
                        leading: const Icon(
                            Icons.circle),
                        title:
                            Text(menuItems[index]),
                        onTap: () {
                          setState(() {
                            selectedIndex =
                                index;
                          });
                        },
                      );
                    },
                  ),
                ),

                /// MAIN CONTENT
                Expanded(
                  child: Container(
                    color:
                        Colors.grey.shade50,
                        child: pages[selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}