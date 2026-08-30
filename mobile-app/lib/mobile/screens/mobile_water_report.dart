
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MobileWaterReport extends StatefulWidget {
  const MobileWaterReport({super.key});

  @override
  State<MobileWaterReport> createState() => _MobileWaterReportState();
}

class _MobileWaterReportState extends State<MobileWaterReport> {
  int selected = 0;

  final List<double> daily = [120, 145, 132, 158, 170, 245, 160];
  final List<double> weekly = [980, 1120, 1243, 1185];
  final List<double> monthly = [4200, 4500, 5100, 4950, 5400, 6100];

  List<double> get currentData {
    switch (selected) {
      case 1:
        return weekly;
      case 2:
        return monthly;
      default:
        return daily;
    }
  }

  List<String> get labels {
    switch (selected) {
      case 1:
        return ["W1", "W2", "W3", "W4"];
      case 2:
        return ["Jan", "Feb", "Mar", "Apr", "May", "Jun"];
      default:
        return ["M", "T", "W", "T", "F", "S", "S"];
    }
  }

  double get total =>
      currentData.fold(0, (sum, item) => sum + item);

  double get average => total / currentData.length;

  double get highest =>
      currentData.reduce((a, b) => a > b ? a : b);

  String get highestLabel =>
      labels[currentData.indexOf(highest)];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Usage Analytics",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Track your water consumption trends",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _tab("Daily", 0),
                _tab("Weekly", 1),
                _tab("Monthly", 2),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Graph
          Card(
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
                  Text(
                    selected == 0
                        ? "Daily Consumption"
                        : selected == 1
                            ? "Weekly Consumption"
                            : "Monthly Consumption",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 240,
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX:
                            (currentData.length - 1).toDouble(),
                        minY: 0,
                        maxY: highest * 1.2,
                        gridData: FlGridData(
                          show: true,
                          horizontalInterval: selected == 2
                              ? 1000
                              : selected == 1
                                  ? 250
                                  : 50,
                        ),
                        borderData:
                            FlBorderData(show: false),

                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: false),
                          ),

                          leftTitles: AxisTitles(
                            axisNameWidget: const Padding(
                              padding:
                                  EdgeInsets.only(bottom: 8),
                              child: Text(
                                "Litres (L)",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: selected == 2
                                  ? 1000
                                  : selected == 1
                                      ? 250
                                      : 50,
                              getTitlesWidget:
                                  (value, meta) {
                                return Text(
                                  value
                                      .toInt()
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),

                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget:
                                  (value, meta) {
                                final index =
                                    value.toInt();
                                if (index >=
                                    labels.length) {
                                  return const SizedBox();
                                }

                                return Padding(
                                  padding:
                                      const EdgeInsets.only(
                                          top: 8),
                                  child: Text(
                                    labels[index],
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              currentData.length,
                              (i) => FlSpot(
                                i.toDouble(),
                                currentData[i],
                              ),
                            ),
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                            ),
                            belowBarData:
                                BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  "Total",
                  "${total.toStringAsFixed(0)} L",
                  Icons.water_drop,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  "Average",
                  "${average.toStringAsFixed(0)} L",
                  Icons.bar_chart,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  "Highest",
                  "${highest.toStringAsFixed(0)} L",
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  "Peak Day",
                  highestLabel,
                  Icons.calendar_today,
                  Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

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
                  child: Text(
                    "Your highest water consumption was on $highestLabel with ${highest.toStringAsFixed(0)} litres. Average usage is ${average.toStringAsFixed(0)} litres.",
                    style: const TextStyle(
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String title, int index) {
    final isSelected = selected == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selected = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding:
              const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blue
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
              radius: 20,
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}