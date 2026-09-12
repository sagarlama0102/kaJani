import 'package:flutter/material.dart';
import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:kajani/features/chat/presentation/pages/chat_coming_soon.dart';
import 'package:kajani/features/dashboard/presentation/pages/bottom_screen_layout/chat_screen.dart';
import 'package:kajani/features/dashboard/presentation/pages/bottom_screen_layout/explore_screen.dart';
import 'package:kajani/features/dashboard/presentation/pages/bottom_screen_layout/home_screen.dart';
import 'package:kajani/features/dashboard/presentation/pages/bottom_screen_layout/notification_screen.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

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
    ChatComingSoonScreen(),

  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      backgroundColor: context.backgroundColor,
      
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
              selectedItemColor: context.primary, // Your signature mint green
              unselectedItemColor: context.textSecondary50,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              showUnselectedLabels: true,

              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Iconsax.home_2),
                  ),
                  activeIcon: Icon(Iconsax.home_2_copy),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Iconsax.search_normal),
                  ),
                  activeIcon: Icon(Iconsax.search_normal_copy),
                  label: "Explore",
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Iconsax.notification_1),
                  ),
                  activeIcon: Icon(Iconsax.notification_1_copy),
                  label: "Notification",
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Iconsax.message_2),
                  ),
                  activeIcon: Icon(Iconsax.message_2_copy),
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
