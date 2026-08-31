// lib/screens/landing_page.dart

import 'package:flutter/material.dart';

import '../components/calasenselogo.dart';
import '../components/featureitem.dart';
import '../components/primarybutton.dart';
import '../constants/appcolors.dart';
import 'signinpage.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  static const double _pagePadding = 28.0;

  late AnimationController _introController;
  late AnimationController _contentController;

  late Animation<double> _logoVerticalAnimation;
  late Animation<double> _logoScaleAnimation;

  late Animation<double> _backgroundOpacity;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _setupAnimations();
    _startAnimation();
  }

  void _setupAnimations() {
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _logoVerticalAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.10,
          end: 0.48,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.48,
          end: 0.44,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 8,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.44,
          end: 0.48,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 8,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(0.48), weight: 15),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.48,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 34,
      ),
    ]).animate(_introController);

    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.15), weight: 66),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.15,
          end: 0.72,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 34,
      ),
    ]).animate(_introController);

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _backgroundOpacity = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    );

    _contentOpacity = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.10, 1.0, curve: Curves.easeOut),
    );

    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  Future<void> _startAnimation() async {
    await _introController.forward();

    if (!mounted) return;

    await _contentController.forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return AnimatedBuilder(
            animation: Listenable.merge([_introController, _contentController]),
            builder: (context, child) {
              const baseLogoSize = 100.0;

              final logoScale = _logoScaleAnimation.value;
              final logoSize = baseLogoSize * logoScale;

              final centerLeft = (width - logoSize) / 2;

              final centerTop =
                  (height * _logoVerticalAnimation.value) - (logoSize / 2);

              final moveProgress = Curves.easeInOutCubic.transform(
                ((_introController.value - 0.66) / 0.34).clamp(0.0, 1.0),
              );

              final finalLeft = _pagePadding;

              final finalTop = safeTop + _pagePadding;

              final logoLeft =
                  centerLeft + (finalLeft - centerLeft) * moveProgress;

              final logoTop = centerTop + (finalTop - centerTop) * moveProgress;

              return Stack(
                children: [
                  const Positioned.fill(child: ColoredBox(color: Colors.white)),

                  Positioned.fill(
                    child: FadeTransition(
                      opacity: _backgroundOpacity,
                      child: Image.asset(
                        'assets/images/bg1.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),

                  Positioned.fill(
                    child: SafeArea(
                      child: FadeTransition(
                        opacity: _contentOpacity,
                        child: SlideTransition(
                          position: _contentSlide,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: _pagePadding,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Spacer(flex: 6),

                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Cala',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Sense.',
                                        style: TextStyle(
                                          color: AppColors.darkGreen,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 2),

                                const Text(
                                  'Scan, Spot, Save Your Crop',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),

                                const SizedBox(height: 26),

                                const FeatureItem(
                                  title: 'Instant Detection',
                                  description: 'Identify diseases in seconds',
                                ),

                                const SizedBox(height: 14),

                                const FeatureItem(
                                  title: 'Smart Recommendations',
                                  description: 'Get AI-powered treatment tips',
                                ),

                                const SizedBox(height: 14),

                                const FeatureItem(
                                  title: 'Track Plant Health',
                                  description: 'Monitor and improve over time',
                                ),

                                const SizedBox(height: 28),

                                PrimaryButton(
                                  text: 'Get Started',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignInPage(),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: _pagePadding),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: logoLeft,
                    top: logoTop,
                    child: Transform.scale(
                      scale: logoScale,
                      alignment: Alignment.topLeft,
                      child: const CalaSenseLogo(size: baseLogoSize),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
