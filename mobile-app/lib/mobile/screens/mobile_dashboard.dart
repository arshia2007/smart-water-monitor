import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MobileDashboard extends StatefulWidget {
  const MobileDashboard({super.key});

  @override
  State<MobileDashboard> createState() => _MobileDashboardState();
}

class _MobileDashboardState extends State<MobileDashboard> {
  final logsRef = FirebaseDatabase.instance.ref("water/logs");
  final currentRef = FirebaseDatabase.instance.ref("water/current");

  late StreamSubscription<DatabaseEvent> logsSub;
  late StreamSubscription<DatabaseEvent> currentSub;

  double todayUsage = 0;
  double yesterdayUsage = 0;
  double flowRate = 0;
  double currentBill = 0;

  final double ratePerLiter = 0.20;

  @override
  void initState() {
    super.initState();
    logsSub = logsRef.onValue.listen(_onLogsChanged);
    currentSub = currentRef.onValue.listen(_onCurrentChanged);
  }

  void _onLogsChanged(DatabaseEvent event) {
    if (event.snapshot.value == null) return;

    final raw = event.snapshot.value as Map<dynamic, dynamic>;
    final now = DateTime.now();

    double today = 0;
    double yesterday = 0;

    for (int i = 0; i <= 1; i++) {
      final day = now.subtract(Duration(days: i));
      final key =
          "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

      double usage = 0;

      if (raw.containsKey(key)) {
        final value = raw[key];
        if (value is Map && value["total"] != null) {
          usage = double.tryParse(value["total"].toString()) ?? 0;
        }
      }

      if (i == 0) {
        today = usage;
      } else {
        yesterday = usage;
      }
    }

    if (!mounted) return;

    setState(() {
      todayUsage = today;
      yesterdayUsage = yesterday;
      currentBill = todayUsage * ratePerLiter;
    });
  }

  void _onCurrentChanged(DatabaseEvent event) {
    if (event.snapshot.value == null) return;

    final data = event.snapshot.value as Map<dynamic, dynamic>;

    final rate =
        double.tryParse(data["flow_rate"]?.toString() ?? "0") ?? 0;

    if (!mounted) return;

    setState(() {
      flowRate = rate;
    });
  }

  @override
  void dispose() {
    logsSub.cancel();
    currentSub.cancel();
    super.dispose();
  }

  String get status {
    if (flowRate == 0) return "No Flow";
    if (flowRate < 10) return "Low Flow";
    if (flowRate < 20) return "Normal";
    return "High Flow";
  }

  Color get statusColor {
    if (flowRate == 0) return Colors.grey;
    if (flowRate < 10) return Colors.blue;
    if (flowRate < 20) return Colors.green;
    return Colors.orange;
  }

  double get changePercent {
    if (yesterdayUsage == 0) return 0;
    return ((todayUsage - yesterdayUsage) / yesterdayUsage) * 100;
  }

  String get insight {
    if (flowRate == 0) {
      return "No water is currently flowing through the meter.";
    }

    if (changePercent < 0) {
      return "Great! You're using ${changePercent.abs().toStringAsFixed(0)}% less water than yesterday.";
    }

    if (changePercent > 0) {
      return "Today's usage is ${changePercent.toStringAsFixed(0)}% higher than yesterday.";
    }

    return "Your water consumption is consistent with yesterday.";
  }

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.now().format(context);

    return RefreshIndicator(
      onRefresh: () async {},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Good day 👋",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Text(
              "Water Overview",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            // Today's Usage
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1565C0),
                    Color(0xFF42A5F5),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "TODAY'S USAGE",
                        style: TextStyle(
                          color: Colors.white70,
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${todayUsage.toStringAsFixed(0)} L",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    changePercent == 0
                        ? "No comparison available"
                        : changePercent < 0
                            ? "↓ ${changePercent.abs().toStringAsFixed(0)}% vs yesterday"
                            : "↑ ${changePercent.toStringAsFixed(0)}% vs yesterday",
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Flow + Bill
            Row(
              children: [
                Expanded(
                  child: _card(
                    icon: Icons.water_drop,
                    color: Colors.blue,
                    title: "Flow Rate",
                    value: "${flowRate.toStringAsFixed(1)}",
                    subtitle: "L/min",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _card(
                    icon: Icons.currency_rupee,
                    color: Colors.green,
                    title: "Current Bill",
                    value: "₹${currentBill.toStringAsFixed(2)}",
                    subtitle: "Estimated",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Live Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: statusColor.withOpacity(.15),
                    child: Icon(
                      Icons.speed,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Live Water Status",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Smart Insight
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Smart Insight",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          insight,
                          style: const TextStyle(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Last Updated
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  "Last updated • $time",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
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
                  color.withOpacity(.12),
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: color,
                fontSize: 12,
              ),
            )
          ],
        ),
      ),
    );
  }
}