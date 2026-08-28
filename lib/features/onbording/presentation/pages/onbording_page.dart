import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/app_colors.dart';
import 'package:kajani/features/auth/presentation/pages/login_page.dart';
import 'package:kajani/features/onbording/presentation/widgets/onbording_content.dart';
import 'package:kajani/features/onbording/presentation/widgets/page_indicator.dart';

class OnboardingPageData {
  final String title;
  final String description;
  final String imagePath;

  OnboardingPageData({
    required this.title,
    required this.imagePath,
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
      imagePath: 'assets/images/v1onboardingscreen.png',
    ),
    OnboardingPageData(
      title: "Connect with People",
      description:
          "Share interests and make \nreal connection with like-minded people",
      imagePath: 'assets/images/v1onboardingscreentwo.png',
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _navigateToLogin() {
    AppRoutes.pushReplacement(context, const LoginPage());
  }

  void _nextPage() {
    if (_currentPage == _pages.length - 1) {
      _navigateToLogin();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, top: 8),
                child: TextButton(
                  onPressed: _navigateToLogin,
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnbordingContent(item: _pages[index]);
                },
              ),
            ),
            PageIndicator(
              itemCount: _pages.length,
              currentPage: _currentPage,
              activeColor: AppColors.primary,
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? "Get Started"
                        : "Continue",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
