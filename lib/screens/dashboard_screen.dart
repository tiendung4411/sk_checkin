import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'attendance_checkin_screen.dart';
import 'ghc_list_screen.dart'; // Import GHCListScreen
// import 'stats_screen.dart';
// import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  String? userId; // Store the userId fetched from SharedPreferences
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });

    // Initialize pages after userId is loaded
    _pages.addAll([
      AttendanceCheckInScreen(),
      GHCListScreen(ownerId: userId ?? ''), // Pass userId to GHCListScreen
      // StatsScreen(),
      // ProfileScreen(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (userId == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: _pages[_currentIndex], // Display the selected page
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          /// Attendance Check-In
          SalomonBottomBarItem(
            icon: const Icon(Icons.qr_code_scanner),
            title: const Text("Attendance"),
            selectedColor: theme.colorScheme.primary,
          ),

          /// Manage Stalls
          SalomonBottomBarItem(
            icon: const Icon(Icons.store),
            title: const Text("Manage Stalls"),
            selectedColor: Colors.green,
          ),

          /// Stats
          SalomonBottomBarItem(
            icon: const Icon(Icons.bar_chart),
            title: const Text("Stats"),
            selectedColor: Colors.orange,
          ),

          /// Profile
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: const Text("Profile"),
            selectedColor: Colors.purple,
          ),
        ],
      ),
    );
  }
}