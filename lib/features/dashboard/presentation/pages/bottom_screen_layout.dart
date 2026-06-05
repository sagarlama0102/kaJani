import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kajani/app/theme/theme_extensions.dart';

class BottomScreenLayout extends StatefulWidget {
  const BottomScreenLayout({super.key});

  @override
  State<BottomScreenLayout> createState() => _BottomScreenLayoutState();
}

class _BottomScreenLayoutState extends State<BottomScreenLayout> {
  int _selectedIndex = 0;

  final List<Widget> lstBottomScreen = const [
    
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
              selectedItemColor: const Color(0xff99DAB3), // Your signature mint green
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
                    child: Icon(Icons.calendar_today_outlined),
                  ),
                  activeIcon: Icon(Icons.calendar_today_rounded),
                  label: "Bookings",
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.favorite_outline_rounded),
                  ),
                  activeIcon: Icon(Icons.favorite_rounded),
                  label: "Wishlist",
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.person_outline_rounded),
                  ),
                  activeIcon: Icon(Icons.person_rounded),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
