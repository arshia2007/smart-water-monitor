import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

class FlowRateScreen extends StatefulWidget {
  const FlowRateScreen({super.key});

  @override
  State<FlowRateScreen> createState() => _FlowRateScreenState();
}

class _FlowRateScreenState extends State<FlowRateScreen> {

  double flowRate = 0;
  double totalToday = 0;
  double peakFlow = 0;

  List<FlSpot> flowHistory = [];
  int timeIndex = 0;

  @override
  void initState() {
    super.initState();

    FirebaseDatabase.instance
        .ref("water/current")
        .onValue
        .listen((event) {

      final data = event.snapshot.value as Map?;

      if (data == null) return;

      double rate = (data["flow_rate"] ?? 0).toDouble();
      double total = (data["total_liters"] ?? 0).toDouble();

      setState(() {

        flowRate = rate;
        totalToday = total;

        if(rate > peakFlow){
          peakFlow = rate;
        }

        flowHistory.add(
          FlSpot(timeIndex.toDouble(), rate),
        );

        if(flowHistory.length > 20){
          flowHistory.removeAt(0);
        }

        timeIndex++;
      });
    });
  }

  String getFlowStatus(){
    if(flowRate == 0) return "No Flow";
    if(flowRate < 10) return "Low Flow";
    if(flowRate < 20) return "Normal Flow";
    return "High Flow";
  }

  Color getStatusColor(){
    if(flowRate == 0) return Colors.grey;
    if(flowRate < 10) return Colors.blue;
    if(flowRate < 20) return Colors.green;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(30),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Real-time Flow Rate",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          const Text(
            "Monitor your water flow in real-time",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 25),

          /// CURRENT FLOW CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),

            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),

            child: Column(
              children: [

                Chip(
                  label: Text(getFlowStatus()),
                  backgroundColor: getStatusColor().withOpacity(0.2),
                ),

                const SizedBox(height: 20),

                const Icon(
                  Icons.speed,
                  size: 60,
                  color: Colors.blue,
                ),

                const SizedBox(height: 10),

                Text(
                  flowRate.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),

                const Text(
                  "Liters per minute",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Updated live",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          /// STATS ROW
          Row(
            children: [

              Expanded(child: statCard(
                  "Total Today",
                  "${totalToday.toStringAsFixed(0)} L")),

              const SizedBox(width:20),

              Expanded(child: statCard(
                  "Average Flow",
                  "${(flowRate).toStringAsFixed(1)} L/min")),

              const SizedBox(width:20),

              Expanded(child: statCard(
                  "Peak Flow",
                  "${peakFlow.toStringAsFixed(1)} L/min")),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            "Flow Rate History",
            style: TextStyle(
                fontSize:18,
                fontWeight: FontWeight.bold),
          ),

          const SizedBox(height:15),

          Expanded(
            child: LineChart(

              LineChartData(

                gridData: FlGridData(show:true),

                borderData: FlBorderData(show:true),

                lineBarsData: [

                  LineChartBarData(
                    isCurved:true,
                    color: Colors.blue,
                    barWidth:3,
                    dotData: FlDotData(show:false),
                    spots: flowHistory,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget statCard(String title,String value){

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            Text(title,
                style: const TextStyle(color: Colors.grey)),

            const SizedBox(height:10),

            Text(value,
                style: const TextStyle(
                    fontSize:20,
                    fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}