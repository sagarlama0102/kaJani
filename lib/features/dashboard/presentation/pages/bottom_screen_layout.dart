import 'package:flutter/material.dart';
import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:kajani/features/dashboard/presentation/pages/bottom_screen_layout/chat_screen.dart';
import 'package:kajani/features/dashboard/presentation/pages/bottom_screen_layout/plan_chat_screen.dart';
import 'package:kajani/features/dashboard/presentation/pages/bottom_screen_layout/explore_screen.dart';
import 'package:kajani/features/dashboard/presentation/pages/bottom_screen_layout/home_screen.dart';
import 'package:kajani/features/dashboard/presentation/pages/bottom_screen_layout/notification_screen.dart';

class BottomScreenLayout extends StatefulWidget {
  const BottomScreenLayout({super.key});

  @override
  State<BottomScreenLayout> createState() => _BottomScreenLayoutState();
}

class _BottomScreenLayoutState extends State<BottomScreenLayout> {
  int _selectedIndex = 0;

  final List<Widget> lstBottomScreen = const [
    HomeScreen(),
    ExploreScreen(),
    NotificationScreen(),
    ChatScreen(),

  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep background color consistent with the theme
      backgroundColor: context.backgroundColor,
      
      // Use IndexedStack to preserve state when switching tabs
      body: IndexedStack(
        index: _selectedIndex,
        children: lstBottomScreen,
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              
              // MODERN STYLING
              backgroundColor: Colors.transparent, // Controlled by the Container
              elevation: 0,
              selectedItemColor: const Color(0xffA78BFA), // Your signature mint green
              unselectedItemColor: context.textSecondary.withOpacity(0.5),
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              showUnselectedLabels: true,

              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.home_outlined),
                  ),
                  activeIcon: Icon(Icons.home_rounded),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.search),
                  ),
                  activeIcon: Icon(Icons.search_rounded),
                  label: "Explore",
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.notifications),
                  ),
                  activeIcon: Icon(Icons.notifications_active_rounded),
                  label: "Notification",
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.chat_bubble_rounded),
                  ),
                  activeIcon: Icon(Icons.chat_rounded),
                  label: "Messages",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
