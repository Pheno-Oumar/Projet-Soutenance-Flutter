import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/route_names.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoAdvanceTimer;

  @override
  void initState() {
    super.initState();
    _scheduleAutoAdvance();
  }

  void _scheduleAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(const Duration(seconds: 8), () {
      if (!mounted) return;
      if (_currentPage < _pages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      } else {
        context.go(RouteNames.home);
      }
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  static const _pages = [
    _OnboardingData(
      image: 'assets/images/onboarding1.jpg',
      flower: 'assets/images/fleuronbaording1.png',
      title: 'Trouvez le salon qui vous correspond',
      description: 'Découvrez les salons près de vous et trouvez\ncelui qui vous correspond.',
    ),
    _OnboardingData(
      image: 'assets/images/onboarding2.png',
      flower: 'assets/images/fleuronboarding2.png',
      title: 'Prenez soin de vous',
      description:
          'Retrouvez vos rendez-vous, favoris et\ninformations capillaires en un seul endroit.',
    ),
    _OnboardingData(
      image: 'assets/images/onboarding3.png',
      flower: 'assets/images/fleuronboarding3.png',
      title: 'Réservez en toute simplicité',
      description:
          'Choisissez votre prestation, votre coiffeur et\nl\'heure qui vous convient.',
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFFFFDFC),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _pages.length,
          onPageChanged: (index) {
            setState(() => _currentPage = index);
            _scheduleAutoAdvance();
          },
          itemBuilder: (context, index) => _OnboardingPage(
            data: _pages[index],
            pageIndex: index,
            currentPage: _currentPage,
            onNext: () {
              if (index < _pages.length - 1) {
                _pageController.animateToPage(
                  index + 1,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                );
              } else {
                context.go(RouteNames.home);
              }
            },
            onDotTap: (page) => _pageController.animateToPage(
              page,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
            ),
          ),
        ),
      );
}

class _OnboardingData {
  const _OnboardingData({
    required this.image,
    required this.flower,
    required this.title,
    required this.description,
  });

  final String image;
  final String flower;
  final String title;
  final String description;
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.data,
    required this.pageIndex,
    required this.currentPage,
    required this.onNext,
    required this.onDotTap,
  });

  final _OnboardingData data;
  final int pageIndex;
  final int currentPage;
  final VoidCallback onNext;
  final ValueChanged<int> onDotTap;

  static const _brown = Color(0xFF68412F);
  static const _muted = Color(0xFF81766F);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final isThirdPage = pageIndex == 2;
    final isShortScreen = size.height < 720;
    final isNarrowScreen = size.width < 360;

    final horizontalPadding = isNarrowScreen ? 16.0 : 20.0;
    final bottomPadding = (bottomInset > 0 ? bottomInset : (isShortScreen ? 12.0 : 20.0));
    final spacingDescButtons = isShortScreen
        ? 14.0
        : (size.height * 0.04).clamp(16.0, 32.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: size.height * (isShortScreen ? 0.64 : 0.68),
          child: Image.asset(data.image, fit: BoxFit.cover, alignment: Alignment.topCenter),
        ),
        Positioned.fill(
          child: ClipPath(
            clipper: const _OnboardingPanelClipper(),
            child: const ColoredBox(color: Color(0xFFFFFDFC)),
          ),
        ),
        Positioned(
          top: size.height * (isShortScreen ? 0.49 : 0.51),
          left: size.width * (isThirdPage ? 0.01 : -0.015),
          width: size.width * (isThirdPage ? 0.98 : 1.03),
          height: size.height * (isThirdPage ? (isShortScreen ? 0.32 : 0.35) : (isShortScreen ? 0.34 : 0.37)),
          child: Image.asset(data.flower, fit: BoxFit.fill, alignment: Alignment.topCenter),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                bottomPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: TextStyle(
                      color: _brown,
                      fontSize: isShortScreen ? 18 : 19,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: isShortScreen ? 6 : 8),
                  Text(
                    data.description,
                    style: TextStyle(
                      color: _muted,
                      fontSize: isShortScreen ? 14.5 : 15.5,
                      height: isShortScreen ? 1.35 : 1.45,
                    ),
                  ),
                  SizedBox(height: spacingDescButtons),
                  SizedBox(
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: isNarrowScreen ? 3 : 4),
                              child: GestureDetector(
                                onTap: () => onDotTap(index),
                                child: _PageDot(
                                  active: currentPage == index,
                                  size: isNarrowScreen ? 11 : 13,
                                ),
                              ),
                            );
                          }),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            height: 40,
                            child: FilledButton.icon(
                              onPressed: onNext,
                              icon: Icon(
                                pageIndex == 2
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 16,
                              ),
                              label: Text(pageIndex == 2 ? 'Commencer' : 'Suivant'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF925D42),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isNarrowScreen ? 9 : 12,
                                ),
                                textStyle: TextStyle(
                                  fontSize: isNarrowScreen ? 12 : 13,
                                  fontWeight: FontWeight.w700,
                                ),
                                shape: const StadiumBorder(),
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
          ),
        ),
      ],
    );
  }
}

class _PageDot extends StatelessWidget {
  const _PageDot({
    required this.active,
    this.size = 13.0,
  });

  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF925D42) : const Color(0xFFC9C1BB),
          shape: BoxShape.circle,
        ),
      );
}

class _OnboardingPanelClipper extends CustomClipper<Path> {
  const _OnboardingPanelClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, size.height * 0.61)
      ..cubicTo(
        size.width * 0.14,
        size.height * 0.57,
        size.width * 0.25,
        size.height * 0.55,
        size.width * 0.36,
        size.height * 0.56,
      )
      ..cubicTo(
        size.width * 0.50,
        size.height * 0.57,
        size.width * 0.59,
        size.height * 0.65,
        size.width * 0.74,
        size.height * 0.67,
      )
      ..cubicTo(
        size.width * 0.84,
        size.height * 0.68,
        size.width * 0.92,
        size.height * 0.66,
        size.width,
        size.height * 0.665,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
