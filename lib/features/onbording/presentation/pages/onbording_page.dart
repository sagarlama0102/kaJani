import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/features/auth/presentation/pages/login_page.dart';
import 'package:kajani/features/onbording/presentation/widgets/onbording_content.dart';
import 'package:kajani/features/onbording/presentation/widgets/page_indicator.dart';

class OnboardingPageData {
  final String title;
  final String description;
  final String imagePath;
  final IconData icon;

  OnboardingPageData({
    required this.title,
    required this.imagePath,
    required this.icon,
    required this.description,
  });
}

class OnbordingPage extends ConsumerStatefulWidget {
  const OnbordingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OnbordingPageState();
}

class _OnbordingPageState extends ConsumerState<OnbordingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: "Discover Plans",
      description: "Explore events and activites \nhappening around you",
      imagePath: 'assets/images/kajanionboardingpage1.png',
      icon: Icons.explore_outlined,
    ),
    OnboardingPageData(
      title: "Connect with People",
      description:
          "Share interests and make \nreal connection with like-minded people",
      imagePath: 'assets/images/kajanionboardingpage2.png',
      icon: Icons.groups_outlined,
    ),
    OnboardingPageData(
      title: "Join & Experience",
      description:
          "Join plans and create memories \nand enjoy real life experience together",
      imagePath: 'assets/images/kajanionboardingpage3.png',
      icon: Icons.celebration_outlined,
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _navigateToLogin() {
    // Using your teacher's preferred routing method
    AppRoutes.pushReplacement(context, const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return OnbordingContent(item: _pages[index]);
              },
            ),
        
            Positioned(
              top: 10,
              right: 20,
              child: TextButton(
                onPressed: _navigateToLogin,
                child: Text("Skip", style: TextStyle(color: Colors.black45)),
              ),
            ),
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              
              child: Column(
                children: [
                  // Your custom dots widget
                  PageIndicator(
                    itemCount: _pages.length,
                    currentPage: _currentPage,
                    activeColor: const Color(0xff99DAB3), // Your brand green
                  ),
                  const SizedBox(height: 20),
        
                  // Next / Get Started Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff142725),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (_currentPage == _pages.length - 1) {
                            _navigateToLogin();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? "GET STARTED"
                              : "NEXT",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
