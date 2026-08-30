import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen>
    with SingleTickerProviderStateMixin {

  late TabController tabController;

  double currentUsage = 0;
  double currentBill = 0;

  final double ratePerLiter = 0.02;

  List<List<String>> monthlyBills = [];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    loadBills();
  }

  void loadBills() {

    FirebaseDatabase.instance
        .ref("water/logs")
        .onValue
        .listen((event) {

      final data = event.snapshot.value as Map?;

      if (data == null) return;

      Map<String,double> monthlyTotals = {};

      currentUsage = 0;

      data.forEach((date,value){

        double liters = (value["total"] ?? 0).toDouble();

        currentUsage += liters;

        String month = date.substring(0,7); // YYYY-MM

        monthlyTotals[month] =
            (monthlyTotals[month] ?? 0) + liters;

      });

      List<List<String>> temp = [];

      monthlyTotals.forEach((month,liters){

        double bill = liters * ratePerLiter;

        temp.add([
          month,
          "${liters.toStringAsFixed(0)} L",
          "₹${bill.toStringAsFixed(2)}",
          "End of Month",
          "Paid"
        ]);

      });

      setState(() {
        monthlyBills = temp.reversed.toList();
        currentBill = currentUsage * ratePerLiter;
      });

    });
  }

  Future<void> downloadBill(List<String> bill) async {

    final pdf = pw.Document();

    pdf.addPage(
        pw.Page(
        build: (pw.Context context) {

            return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

                pw.Text(
                "Water Meter Bill",
                style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                ),
                ),

                pw.SizedBox(height: 20),

                pw.Text("Meter ID: WM001"),
                pw.Text("Customer: Rajesh Kumar"),

                pw.SizedBox(height: 20),

                pw.Text("Billing Period: ${bill[0]}"),
                pw.Text("Usage: ${bill[1]}"),
                pw.Text("Amount: ${bill[2]}"),

                pw.SizedBox(height: 30),

                pw.Text("Status: Paid"),

                pw.SizedBox(height: 40),

                pw.Text("Thank you for using the Smart Water Monitoring System"),

            ],
            );
        },
        ),
        );

        await Printing.layoutPdf(
            onLayout: (format) async => pdf.save(),
        );
    }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(30),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// PAGE TITLE
          const Text(
            "Bills & Payments",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          const Text(
            "View and manage your water bills",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 25),

          /// CURRENT BILL CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Current Bill - March 2026",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "Billing cycle in progress",
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Usage"),
                            Text(
                              "${currentUsage.toStringAsFixed(0)} L",
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),

                        const SizedBox(width: 40),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Amount"),
                            Text(
                              "₹${currentBill.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),

                      ],
                    )
                  ],
                ),

                const Chip(
                  label: Text("Pending"),
                  backgroundColor: Color(0xfffef3c7),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          /// TABS
          TabBar(
            controller: tabController,
            labelColor: Colors.blue,
            tabs: const [
              Tab(text: "Monthly Bills"),
              Tab(text: "Annual Summary"),
            ],
          ),

          const SizedBox(height: 20),

          /// TAB CONTENT
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [

                /// MONTHLY BILL TABLE
                SingleChildScrollView(
                  child: DataTable(

                    columns: const [
                      DataColumn(label: Text("Period")),
                      DataColumn(label: Text("Usage")),
                      DataColumn(label: Text("Amount")),
                      DataColumn(label: Text("Due Date")),
                      DataColumn(label: Text("Status")),
                      DataColumn(label: Text("Actions")),
                    ],

                    rows: monthlyBills.map((bill) {

                      return DataRow(cells: [

                        DataCell(Text(bill[0])),

                        DataCell(Text(bill[1])),

                        DataCell(Text(bill[2])),

                        DataCell(Text(bill[3])),

                        const DataCell(
                          Chip(
                            label: Text("Paid"),
                            backgroundColor: Color(0xffdcfce7),
                          ),
                        ),

                        DataCell(
                          TextButton.icon(
                            onPressed: () {
                                downloadBill(bill);
                            },
                            icon: const Icon(Icons.download),
                            label: const Text("Download"),
                        ))


                      ]);

                    }).toList(),
                  ),
                ),

                /// ANNUAL SUMMARY
                const Center(
                  child: Text(
                    "Annual Summary Coming Soon",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}