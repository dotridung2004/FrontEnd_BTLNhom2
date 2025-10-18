import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import 'home_screen.dart';
import 'schedule_screen.dart';
import 'attendance_screen.dart';
import 'leave_makeup_screen.dart';
import 'report_screen.dart';
import 'profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 1; // Start at Schedule screen

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreenContent(),
    ScheduleScreen(),
    AttendanceScreen(),
    LeaveMakeupScreen(),
    ReportScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.2),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: const Color(0xFF2E7BC4),
            child: const Text('TLU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thuy Loi', style: TextStyle(color: Color(0xFF1e293b), fontSize: 18, fontWeight: FontWeight.bold)),
            Text('University', style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: Colors.grey[800], size: 30),
                onPressed: () {},
              ),
              Positioned(
                top: 10,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 16.0),
            child: GestureDetector(
              onTap: () => _onItemTapped(5), // Navigate to profile screen (index 5)
              child: const CircleAvatar(
                backgroundColor: Color(0xFF2E7BC4),
                child: Text('D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ),
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7BC4),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home), label: AppLocalizations.of(context)!.bottomNavHome),
          BottomNavigationBarItem(icon: const Icon(Icons.calendar_today_outlined), activeIcon: const Icon(Icons.calendar_today), label: AppLocalizations.of(context)!.bottomNavSchedule),
          BottomNavigationBarItem(icon: const Icon(Icons.check_circle_outline), activeIcon: const Icon(Icons.check_circle), label: AppLocalizations.of(context)!.bottomNavAttendance),
          BottomNavigationBarItem(icon: const Icon(Icons.access_time_outlined), activeIcon: const Icon(Icons.access_time_filled), label: AppLocalizations.of(context)!.bottomNavLeave),
          BottomNavigationBarItem(icon: const Icon(Icons.bar_chart_outlined), activeIcon: const Icon(Icons.bar_chart), label: AppLocalizations.of(context)!.bottomNavReport),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline), activeIcon: const Icon(Icons.person), label: AppLocalizations.of(context)!.bottomNavProfile),
        ],
      ),
    );
  }
}