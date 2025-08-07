// =======================>> Dart Core
import 'dart:async';
import 'dart:math';
import 'dart:ui';

// =======================>> Flutter Core
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// =======================>> Third-party Packages
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

// =======================>> Providers Components
import 'package:calendar/providers/global/auth_provider.dart';
import 'package:calendar/providers/global/setting_provider.dart';

// =======================>> Shared Components
import 'package:calendar/shared/component/elevatedbutton_.dart';
import 'package:calendar/shared/entity/helper/colors.dart';

// =======================>> Local Utilities
import 'package:calendar/app_routes.dart';


class Onboarding3 extends StatefulWidget {
  final bool buildButtons;
  const Onboarding3({super.key, this.buildButtons = true});

  @override
  State<Onboarding3> createState() => _Onboarding3State();
}

class _Onboarding3State extends State<Onboarding3>
    with SingleTickerProviderStateMixin {
  late final TabController controller;
  Timer? timer;

  static const images = <String>[
    'assets/onboarding/1-alt.png',
    'assets/onboarding/2-alt.png',
    'assets/onboarding/3-alt.png',
    // 'assets/onboarding/4.gif',
  ];
  static const titles = <String>[
    '',
    '',
    '',
    // 'onboarding4.title',
  ];
  static const subtitles = <String>[
    '',
    '',
    '',
    // 'onboarding4.subtitle',
  ];

  @override
  void initState() {
    controller = TabController(
      length: images.length,
      vsync: this,
      animationDuration: const Duration(milliseconds: 800),
    );
    super.initState();
    updateTimer();
  }

  void updateTimer() {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 8), () {
      if (currentPage >= (images.length - 1)) return;
      controller.animateTo((currentPage + 1) % images.length);
    });
  }

  int get currentPage => controller.index;
  int get lastPage => controller.previousIndex;

  Widget buildTab(int index) {
    return Container(
      width: double.infinity,
      height: 380,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.topCenter,
                height: 80,
                child: Text(
                  subtitles[index],
                  // align: TextAlign.center,
                  // color: HColors.whitegrey.withAlpha(200),
                  maxLines: 5,
                  // size: EFontSize.content,
                ),
              ),
              SizedBox(
                height: 300,
                child: SingleChildScrollView(
                  child: Image.asset(
                    images[index],
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Stack(
        children: [
          Positioned.fill(child: _Backdrop(controller)),
          Positioned.fill(
            child: TabBarView(
              physics: const BouncingScrollPhysics(),
              controller: controller,
              children: List.generate(images.length, (i) => buildTab(i)),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: Shimmer(
                          period: const Duration(seconds: 6),
                          gradient: const LinearGradient(
                            tileMode: TileMode.mirror,
                            colors: [
                              Color(0xff13c4e9),
                              Color(0xffd7ae08),
                              Color(0xff13c4e9),
                              Color(0xffd7ae08),
                            ],
                          ),
                          child: AnimatedBuilder(
                            animation: controller.animation!,
                            builder: (ctx, child) {
                              updateTimer();
                              final normalized = clampDouble(
                                controller.animation!.value - currentPage,
                                -1,
                                1,
                              );

                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (currentPage > 0)
                                    Opacity(
                                      opacity: normalized < 0 ? -normalized : 0,
                                      child: Transform.translate(
                                        offset: Offset(
                                          -150 * (1 + normalized),
                                          0,
                                        ),
                                        child: Text(
                                          titles[currentPage - 1],
                                          // align: TextAlign.center,
                                          // fontWeight: FontWeight.w500,
                                          // size: EFontSize.medium,
                                          maxLines: 3,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  if (currentPage < titles.length - 1)
                                    Opacity(
                                      opacity: normalized > 0 ? normalized : 0,
                                      child: Transform.translate(
                                        offset: Offset(
                                          150 * (1 - normalized),
                                          0,
                                        ),
                                        child: Text(
                                          titles[currentPage + 1],

                                          maxLines: 3,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),

                                  Opacity(
                                    opacity: 1.0 - normalized.abs(),
                                    child: Transform.translate(
                                      offset: Offset(-normalized * 150, 0),
                                      child: Text(
                                        titles[currentPage],
                                        // align: TextAlign.center,
                                        // fontWeight: FontWeight.w500,
                                        // size: EFontSize.medium,
                                        maxLines: 3,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 440),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FadeIn(
                          duration: const Duration(milliseconds: 1400),
                          curve: Curves.easeOut,
                          delay: const Duration(milliseconds: 300),
                          child: TabPageSelector(
                            controller: controller,
                            selectedColor: Colors.white.withAlpha(200),
                          ),
                        ),
                        if (widget.buildButtons) ...[
                          const SizedBox(height: 15),
                          CustomElevatedButton(
                            label: "ចូលគណនី",
                            borderRadius: 15,
                            // isSecondary: true,
                            backgroundColor: HColors.blue,
                            onPressed: () => _navigateToLogin(context),
                          ),
                          // const SizedBox(height: 8),
                          // CustomElevatedButton(
                          //   label: "login".tr,
                          //   // borderRadius: 15,
                          //   isSecondary: true,
                          //   backgroundColor: HColors.blue,
                          //   onPressed: () {
                          //     // HapticFeedback.lightImpact();
                          //     Get.to(() => const LoginOptionScreen());
                          //   },
                          // ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              style: TextStyle(color: Colors.white),
                              "version 2.0.0",
                              // size: EFontSize.small,
                              // color: HColors.darkgrey.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!widget.buildButtons)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ZoomIn(
                  // delay: const Duration(milliseconds: 20),
                  duration: const Duration(milliseconds: 1000),
                  child: FadeIn(
                    // delay: const Duration(milliseconds: 20),
                    duration: const Duration(milliseconds: 1000),
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        backgroundBlendMode: BlendMode.lighten,
                        color: const Color.fromARGB(120, 184, 214, 255),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _navigateToLogin(BuildContext context) async {
    try {
      await Provider.of<SettingProvider>(
        context,
        listen: false,
      ).handleSetOnboardingCompleted();
      Provider.of<AuthProvider>(context, listen: false).setIsChecking(false);
      if (!context.mounted) return;
      context.go(AppRoutes.home);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete onboarding: $e')),
      );
    }
  }
}

class _Backdrop extends StatelessWidget {
  final TabController controller;

  const _Backdrop(this.controller);

  @override
  Widget build(BuildContext context) {
    final double bodyWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height / 2,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRect(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: 8,
                      sigmaY: 8,
                      tileMode: TileMode.mirror,
                    ),
                    child: Stack(
                      children: [
                        AnimatedBuilder(
                          animation: controller.animation!,
                          builder: (ctx, child) {
                            final currentValue = controller.animation!.value;
                            final middleIndex =
                                (_Onboarding3State.images.length - 1) / 2;

                            // Offset centered on the middle page
                            final offset = currentValue - middleIndex;
                            return Positioned(
                              left: (-bodyWidth / 2) - (offset * bodyWidth / 4),
                              width: bodyWidth * 2,
                              bottom: 0,
                              top: 0,
                              child: FadeInImage(
                                placeholder: MemoryImage(
                                  Uint8List.fromList(const [
                                    0x89,
                                    0x50,
                                    0x4E,
                                    0x47,
                                    0x0D,
                                    0x0A,
                                    0x1A,
                                    0x0A,
                                    0x00,
                                    0x00,
                                    0x00,
                                    0x0D,
                                    0x49,
                                    0x48,
                                    0x44,
                                    0x52,
                                    0x00,
                                    0x00,
                                    0x00,
                                    0x01,
                                    0x00,
                                    0x00,
                                    0x00,
                                    0x01,
                                    0x08,
                                    0x06,
                                    0x00,
                                    0x00,
                                    0x00,
                                    0x1F,
                                    0x15,
                                    0xC4,
                                    0x89,
                                    0x00,
                                    0x00,
                                    0x00,
                                    0x0A,
                                    0x49,
                                    0x44,
                                    0x41,
                                    0x54,
                                    0x78,
                                    0x9C,
                                    0x63,
                                    0x00,
                                    0x01,
                                    0x00,
                                    0x00,
                                    0x05,
                                    0x00,
                                    0x01,
                                    0x0D,
                                    0x0A,
                                    0x2D,
                                    0xB4,
                                    0x00,
                                    0x00,
                                    0x00,
                                    0x00,
                                    0x49,
                                    0x45,
                                    0x4E,
                                    0x44,
                                    0xAE,
                                    0x42,
                                    0x60,
                                    0x82,
                                  ]),
                                ),
                                image: AssetImage(
                                  'assets/images/PhnomPenh.png',
                                ),
                                alignment: Alignment(0, 0.2),
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [0.0, 0.4],
                      colors: [HColors.blue, HColors.blue.withAlpha(100)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(child: CustomPaint(painter: DiagonalFillPainter())),
      ],
    );
  }
}

class DiagonalFillPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xff0f172a)
          ..style = PaintingStyle.fill;

    final isTallEnough = size.height > size.width;

    final Path path;

    if (isTallEnough) {
      // 15° upward diagonal line from center-left
      final start = Offset(0, size.height / 2);
      final angleRadians = -15 * pi / 180;
      final dx = size.width;
      final dy = tan(angleRadians) * dx;
      final end = Offset(dx, start.dy + dy);

      path =
          Path()
            ..moveTo(start.dx, start.dy)
            ..lineTo(end.dx, end.dy)
            ..lineTo(size.width, size.height)
            ..lineTo(0, size.height)
            ..close();
    } else {
      final start = Offset(0, size.height * 0.75);
      final end = Offset(size.width, size.height * 0.25);

      path =
          Path()
            ..moveTo(start.dx, start.dy)
            ..lineTo(end.dx, end.dy)
            ..lineTo(size.width, size.height)
            ..lineTo(0, size.height)
            ..close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
