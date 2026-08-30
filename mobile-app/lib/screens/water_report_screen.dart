import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

class WaterReportScreen extends StatefulWidget {
  const WaterReportScreen({super.key});

  @override
  State<WaterReportScreen> createState() => _WaterReportScreenState();
}

class _WaterReportScreenState extends State<WaterReportScreen> {
  final DatabaseReference logsRef =
      FirebaseDatabase.instance.ref("water/logs");

  Map<String, double> last7Data = {};
  Map<String, double> monthlyData = {};

  double todayUsage = 0;
  double last7DaysUsage = 0;

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  void fetchLogs() {
    logsRef.onValue.listen((event) {
      if (event.snapshot.value == null) return;

      final rawData = event.snapshot.value as Map<dynamic, dynamic>;

      Map<String, double> tempLast7 = {};
      Map<String, List<double>> monthlyCollection = {};

      double todayTotal = 0;
      double last7Total = 0;

      DateTime now = DateTime.now();
      DateTime sevenDaysAgo = now.subtract(const Duration(days: 6));

      rawData.forEach((key, value) {
        String dateKey = key.toString();

        if (value["total"] != null) {
          double usage =
              double.tryParse(value["total"].toString()) ?? 0;

          DateTime date = DateTime.parse(dateKey);

          if (date.year == now.year &&
              date.month == now.month &&
              date.day == now.day) {
            todayTotal += usage;
          }

          if (!date.isBefore(sevenDaysAgo)) {
            last7Total += usage;
          }

          String monthKey =
              "${date.year}-${date.month.toString().padLeft(2, '0')}";

          monthlyCollection.putIfAbsent(monthKey, () => []);
          monthlyCollection[monthKey]!.add(usage);
        }
      });

      Map<String, double> monthlyAvg = {};
      monthlyCollection.forEach((month, values) {
        double sum = values.reduce((a, b) => a + b);
        monthlyAvg[month] = sum / values.length;
      });

      for (int i = 6; i >= 0; i--) {
        DateTime day = now.subtract(Duration(days: i));

        String dateKey =
            "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

        double usage = 0;

        if (rawData.containsKey(dateKey) &&
            rawData[dateKey]["total"] != null) {
          usage = double.tryParse(
                  rawData[dateKey]["total"].toString()) ??
              0;
        }

        tempLast7[dateKey] = usage;
      }

      setState(() {
        last7Data = tempLast7;
        monthlyData = monthlyAvg;
        todayUsage = todayTotal;
        last7DaysUsage = last7Total;
      });
    });
  }

  List<FlSpot> generateSpots(Map<String, double> data) {
    List<FlSpot> spots = [];
    final sortedKeys = data.keys.toList()..sort();

    for (int i = 0; i < sortedKeys.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[sortedKeys[i]]!));
    }
    return spots;
  }

  double getMaxY(Map<String, double> data) {
    if (data.isEmpty) return 10;

    double maxValue =
        data.values.reduce((a, b) => a > b ? a : b);

    return (maxValue * 1.2).ceilToDouble();
  }

  Widget buildChart(
      String title, Map<String, double> data, bool isMonthly) {
    final sortedKeys = data.keys.toList()..sort();
    double maxY = getMaxY(data);

    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX:
                        sortedKeys.isEmpty ? 0 : sortedKeys.length - 1,
                    minY: 0,
                    maxY: maxY,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget:
                              (value, meta) {
                            if (value % 1 != 0)
                              return const SizedBox();

                            int index = value.toInt();
                            if (index < 0 ||
                                index >= sortedKeys.length)
                              return const SizedBox();

                            String formatted;

                            if (isMonthly) {
                              String monthKey =
                                  sortedKeys[index];
                              int month = int.parse(
                                  monthKey.split('-')[1]);

                              const months = [
                                "Jan","Feb","Mar","Apr","May","Jun",
                                "Jul","Aug","Sep","Oct","Nov","Dec"
                              ];

                              formatted =
                                  months[month - 1];
                            } else {
                              DateTime date =
                                  DateTime.parse(
                                      sortedKeys[index]);
                              formatted =
                                  "${date.day}/${date.month}";
                            }

                            return Text(formatted,
                                style: const TextStyle(
                                    fontSize: 10));
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: maxY > 5 ? maxY / 5 : 1,
                          getTitlesWidget:
                              (value, meta) {
                            return Text(
                                "${value.toInt()}L",
                                style: const TextStyle(
                                    fontSize: 10));
                          },
                        ),
                      ),
                      topTitles: AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: generateSpots(data),
                        isCurved: true,
                        barWidth: 4,
                        dotData:
                            FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Water Usage Report"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text("Today's Usage"),
                          const SizedBox(height: 6),
                          Text(
                            "${todayUsage.toStringAsFixed(2)} L",
                            style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text("Last 7 Days"),
                          const SizedBox(height: 6),
                          Text(
                            "${last7DaysUsage.toStringAsFixed(2)} L",
                            style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            buildChart("Last 7 Days Usage", last7Data, false),
            const SizedBox(height: 20),
            buildChart("Monthly Average Usage", monthlyData, true),
          ],
        ),
      ),
    );
  }
}