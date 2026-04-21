import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/features/onbording/presentation/pages/onbording_page.dart'; // CRITICAL IMPORT

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation; 

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _startAnimations();
  }

  void _setupAnimation() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  void _startAnimations() async {
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    _slideController.forward();
  }

//     Future<void> _navigateToNext() async {
//   await Future.delayed(const Duration(seconds: 3));
//   if (!mounted) return;

//   final userSessionService = ref.read(userSessionServiceProvider);
//   final isLoggedIn = userSessionService.isLoggedIn();

//   if (isLoggedIn) {
    
//     await ref.read(authViewModelProvider.notifier).getCurrentUser();

//     if (mounted) {
//       AppRoutes.pushReplacement(context, const BottomScreenLayout());
//     }
//   } else {
//     AppRoutes.pushReplacement(context, const OnbordingPage());
//   }
// }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SizedBox(
                height: 200,
                width: 200,
                child: Image.asset(
                  'assets/images/kajanilogo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}