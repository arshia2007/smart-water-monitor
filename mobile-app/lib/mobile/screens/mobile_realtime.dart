import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MobileRealtime extends StatefulWidget {
  const MobileRealtime({super.key});

  @override
  State<MobileRealtime> createState() => _MobileRealtimeState();
}

class _MobileRealtimeState extends State<MobileRealtime> {
  final DatabaseReference ref =
      FirebaseDatabase.instance.ref("water/current");

  late StreamSubscription<DatabaseEvent> sub;

  double flowRate = 0;
  double todayUsage = 0;
  String lastUpdated = "--:--:--";

  @override
  void initState() {
    super.initState();

    sub = ref.onValue.listen((event) {
      if (event.snapshot.value == null) return;

      final data = event.snapshot.value as Map<dynamic, dynamic>;

      final now = DateTime.now();

      setState(() {
        flowRate = double.tryParse(
              data["flow_rate"]?.toString() ?? "0",
            ) ??
            0;

        todayUsage = double.tryParse(
              data["total_today"]?.toString() ?? "0",
            ) ??
            0;

        lastUpdated =
            "${now.hour.toString().padLeft(2, '0')}:"
            "${now.minute.toString().padLeft(2, '0')}:"
            "${now.second.toString().padLeft(2, '0')}";
      });
    });
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  String get flowStatus {
    if (flowRate == 0) return "No Flow";
    if (flowRate < 10) return "Low Flow";
    if (flowRate < 20) return "Normal Flow";
    return "High Flow";
  }

  Color get statusColor {
    if (flowRate == 0) return Colors.grey;
    if (flowRate < 10) return Colors.blue;
    if (flowRate < 20) return Colors.green;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Live Monitoring",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Real-time water flow updates",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 28),

          // Circular Live Flow Meter
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade100,
              ),
              child: Center(
                child: Container(
                  width: 155,
                  height: 155,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1976D2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        flowRate.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "L/min",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "LIVE FLOW RATE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: _infoCard(
                  icon: Icons.water_drop,
                  title: "Flow Status",
                  value: flowStatus,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoCard(
                  icon: Icons.opacity,
                  title: "Today Used",
                  value: "${todayUsage.toStringAsFixed(0)} L",
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // System Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "System Status",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Monitoring Active",
                        style: TextStyle(
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Last Updated
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.sync,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Last Updated",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(lastUpdated),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  color.withOpacity(0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}