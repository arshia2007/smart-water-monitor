import 'package:flutter/material.dart';

import 'screens/mobile_dashboard.dart';
import 'screens/mobile_water_report.dart';
import 'screens/mobile_bills.dart';
import 'screens/mobile_realtime.dart';
import 'screens/mobile_profile.dart';

class MobileShell extends StatefulWidget {
  const MobileShell({super.key});

  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
  int selectedIndex = 0;

  final List<String> titles = const [
    'Dashboard',
    'Water Report',
    'Bills',
    'Real-time',
    'Profile',
  ];

  Widget get currentPage {
    switch (selectedIndex) {
      case 0:
        return const MobileDashboard();
      case 1:
        return const MobileWaterReport();
      case 2:
        return const MobileBills();
      case 3:
        return const MobileRealtime();
      case 4:
        return const MobileProfile();
      default:
        return const MobileDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: currentPage,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Report',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Bills',
          ),
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop),
            label: 'Live',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}