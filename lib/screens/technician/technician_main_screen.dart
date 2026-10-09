import 'package:flutter/material.dart';

import 'technician_home_content.dart';
import 'nearby_requests_screen.dart';
import 'technician_jobs_screen.dart';
import '../profile/technician_profile_screen.dart';

class TechnicianMainScreen extends StatefulWidget {
  const TechnicianMainScreen({super.key});

  @override
  State<TechnicianMainScreen> createState() => _TechnicianMainScreenState();
}

class _TechnicianMainScreenState extends State<TechnicianMainScreen> {
  int _currentIndex = 0;

  final List<Widget> pages = const [
    TechnicianHomeContent(),
    NearbyRequestsScreen(),
    TechnicianJobsScreen(),
    TechnicianProfileScreen(),
  ];

  void _changeScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _changeScreen,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Solicitudes',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Trabajos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
