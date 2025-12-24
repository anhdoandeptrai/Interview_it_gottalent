import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/splash_constants.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _slideAnimation;

  String _loadingText = 'Initializing...';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: SplashConstants.logoAnimationDuration,
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: SplashConstants.textAnimationDuration,
      vsync: this,
    );

    // Progress animation controller
    _progressController = AnimationController(
      duration: SplashConstants.progressAnimationDuration,
      vsync: this,
    );

    // Logo scale animation
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: SplashConstants.logoAnimationCurve,
    ));

    // Text fade animation
    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: SplashConstants.textAnimationCurve,
    ));

    // Progress animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: SplashConstants.progressAnimationCurve,
    ));

    // Slide animation for text
    _slideAnimation = Tween<Offset>(
      begin: SplashConstants.slideAnimationBegin,
      end: SplashConstants.slideAnimationEnd,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: SplashConstants.slideAnimationCurve,
    ));
  }

  Future<void> _startInitialization() async {
    print('Starting splash initialization...');

    // Add a timeout to prevent the app from getting stuck
    final timeoutDuration = const Duration(seconds: 10);

    try {
      await Future.wait([
        _performAnimationsAndSteps(),
        Future.delayed(
            SplashConstants.minimumSplashDuration), // Minimum display time
      ]).timeout(timeoutDuration);
    } catch (e) {
      print('Initialization timeout or error: $e');
    }

    // Navigate to next screen only if still mounted
    if (mounted) {
      await _navigateToNextScreen();
    }
  }

  Future<void> _performAnimationsAndSteps() async {
    // Start logo animation
    if (mounted) _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Start text animation
    if (mounted) _textController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Start progress animation
    if (mounted) _progressController.forward();

    // Simulate initialization steps
    await _performInitializationSteps();

    // Wait a bit more for initialization to complete
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _navigateToNextScreen() async {
    try {
      // Ensure we have the auth controller
      if (!Get.isRegistered<AuthController>()) {
        print('AuthController not registered, navigating to login');
        Get.offAllNamed(AppRoutes.LOGIN);
        return;
      }

      final authController = Get.find<AuthController>();

      // Use the new checkAuthStatus method to avoid navigation conflicts
      final isAuthenticated = await authController.checkAuthStatus();

      if (isAuthenticated) {
        print('User is authenticated, navigating to main navigation');
        Get.offAllNamed(AppRoutes.MAIN_NAVIGATION);
      } else {
        print('User is not authenticated, navigating to login');
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } catch (e) {
      print('Navigation error: $e');
      // Fallback to login if there's any error
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  Future<void> _performInitializationSteps() async {
    print('Starting initialization steps...');
    for (int i = 0; i < SplashConstants.loadingSteps.length; i++) {
      // Check if widget is still mounted before calling setState
      if (mounted) {
        final step = SplashConstants.loadingSteps[i];
        print('Performing step ${i + 1}: ${step['text']}');
        setState(() {
          _loadingText = step['text'] as String;
          _progress = (i + 1) / SplashConstants.loadingSteps.length;
        });
      }

      await Future.delayed(Duration(
          milliseconds: SplashConstants.loadingSteps[i]['delay'] as int));

      // Break the loop if widget is no longer mounted
      if (!mounted) {
        print('Widget no longer mounted, breaking initialization');
        break;
      }
    }
    print('Initialization steps completed');
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: SplashConstants.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo with Enhanced Design
                      AnimatedBuilder(
                        animation: _logoAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoAnimation.value,
                            child: Container(
                              width: SplashConstants.logoSize + 20,
                              height: SplashConstants.logoSize + 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SplashConstants.logoGradient,
                                boxShadow: SplashConstants.logoShadow,
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.psychology_rounded,
                                  size: 70,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      // Animated App Title with Enhanced Styling
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _textAnimation,
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => SplashConstants
                                    .textGradient
                                    .createShader(bounds),
                                child: Text(
                                  SplashConstants.appName,
                                  style: SplashConstants.titleStyle.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(
                                  height:
                                      SplashConstants.titleToTaglineSpacing),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: SplashConstants.primaryColor
                                        .withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  SplashConstants.appTagline,
                                  style: SplashConstants.taglineStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Loading Section with Enhanced Design
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Loading Text with Icon
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          final currentStep =
                              (_progress * SplashConstants.loadingSteps.length)
                                  .floor();
                          final stepData =
                              currentStep < SplashConstants.loadingSteps.length
                                  ? SplashConstants.loadingSteps[currentStep]
                                  : SplashConstants.loadingSteps.last;

                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Row(
                              key: ValueKey(_loadingText),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    stepData['icon'] ?? '⚡',
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: Text(
                                    _loadingText,
                                    style: SplashConstants.loadingTextStyle,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(
                          height: SplashConstants.textToProgressSpacing),

                      // Enhanced Progress Bar with Animation
                      Container(
                        width: double.infinity,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white.withValues(alpha: 0.1),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Main progress fill
                            AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (context, child) {
                                return FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _progress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      gradient:
                                          SplashConstants.progressGradient,
                                      boxShadow: [
                                        BoxShadow(
                                          color: SplashConstants.primaryColor
                                              .withValues(alpha: 0.6),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Shimmer overlay effect
                            AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    (_progressController.value * 2 - 1) *
                                        MediaQuery.of(context).size.width *
                                        0.8,
                                    0,
                                  ),
                                  child: Container(
                                    width: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withValues(alpha: 0.4),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                          height: SplashConstants.progressToPercentageSpacing),

                      // Progress Percentage with Enhanced Style
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: SplashConstants.primaryColor
                                    .withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${(_progress * 100).toInt()}%',
                              style: SplashConstants.percentageStyle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom section with version and designer info
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FadeTransition(
                      opacity: _textAnimation,
                      child: Column(
                        children: [
                          Text(
                            SplashConstants.appVersion,
                            style: SplashConstants.versionStyle,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              SplashConstants.designedBy,
                              style: SplashConstants.designerStyle,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            SplashConstants.copyright,
                            style: SplashConstants.copyrightStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Animated Loading Dots Widget
class AnimatedLoadingDots extends StatefulWidget {
  const AnimatedLoadingDots({super.key});

  @override
  State<AnimatedLoadingDots> createState() => _AnimatedLoadingDotsState();
}

class _AnimatedLoadingDotsState extends State<AnimatedLoadingDots>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animations = List.generate(3, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2,
            0.6 + index * 0.2,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white
                    .withValues(alpha: _animations[index].value * 0.8),
              ),
            );
          },
        );
      }),
    );
  }
}
