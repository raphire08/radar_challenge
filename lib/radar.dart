import 'dart:math';

import 'package:animated_radar/app_colors.dart';
import 'package:animated_radar/app_images.dart';
import 'package:animated_radar/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Radar extends StatefulWidget {
  const Radar({Key? key, required this.screenHeight, required this.screenWidth})
      : super(key: key);
  final double screenHeight;
  final double screenWidth;

  @override
  _RadarState createState() => _RadarState();
}

class _RadarState extends State<Radar> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  final double dtrSmallHeight = 68;
  final double dtrSmallWidth = 64;
  final double dtrBig = 100;
  late double r1;
  late double r2;
  late double r3;
  late final double youSize;
  late final Offset radarCenter;
  late Rect positionStart1;
  late Rect positionStart2;
  late Rect positionStart3;
  late Rect positionStart4;
  late Rect positionEnd1;
  late Rect positionEnd2;
  late Rect positionEnd3;
  late Rect positionEnd4;
  bool shouldTranslate = true;
  final Random _random = Random();
  int count = 0;
  List<Widget> widgets = [];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _fadeController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _rotationAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.linear));
    _rotationAnimation.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        if (count < 20) {
          Future.delayed(Duration(milliseconds: 100)).then((value) {
            setState(() {
              widgets.addAll([
                getDtrWidget(positionEnd1),
                getDtrWidget(positionEnd2),
                getDtrWidget(positionEnd3),
                getDtrWidget(positionEnd4),
                getTextWidget(positionEnd1, dtrBig / 2),
                getTextWidget(positionEnd2, dtrBig / 2),
                getTextWidget(positionEnd3, dtrBig / 2),
                getTextWidget(positionEnd4, dtrBig / 2),
              ]);
              count = count + 4;
              shouldTranslate = !shouldTranslate;
              setPosition(count);
            });
            _controller.forward(from: 0);
            shouldTranslate
                ? _fadeController.forward()
                : _fadeController.reverse();
          });
        } else {
          setState(() {
            count = 0;
            shouldTranslate = !shouldTranslate;
            widgets = [];
            _controller.reset();
            setPosition(count);
          });
        }
      }
    });
    setRadius();
    setRadar();
    setPosition(count);
  }

  void setRadius() {
    r1 = 0.9 * widget.screenWidth;
    r2 = 0.75 * widget.screenWidth;
    r3 = 0.6 * widget.screenWidth;
  }

  void setRadar() {
    youSize = widget.screenWidth * 0.7;
    radarCenter = Offset(widget.screenWidth / 2, widget.screenHeight * 0.3);
  }

  void setPosition(count) {
    positionStart1 = getStartRect(getRandomRadius(), getRandomAngle());
    positionStart2 = getStartRect(getRandomRadius(), getRandomAngle());
    positionStart3 = getStartRect(getRandomRadius(), getRandomAngle());
    positionStart4 = getStartRect(getRandomRadius(), getRandomAngle());
    positionEnd1 = getEndPosition(count + 1);
    positionEnd2 = getEndPosition(count + 2);
    positionEnd3 = getEndPosition(count + 3);
    positionEnd4 = getEndPosition(count + 4);
  }

  Rect getStartRect(double r, double angle) {
    double x = radarCenter.dx + (r * cos(angle));
    double y = radarCenter.dy - (r * sin(angle));
    return Rect.fromCenter(
        center: Offset(x, y), width: dtrSmallWidth, height: dtrSmallHeight);
  }

  Rect getEndPosition(int number) {
    double x = widget.screenWidth / 4;
    double y = widget.screenHeight * 0.1 * (number + 6);
    return Rect.fromCenter(center: Offset(x, y), width: dtrBig, height: dtrBig);
  }

  double getRandomAngle() {
    return _random.nextDouble() * 2 * pi;
  }

  double getRandomRadius() {
    int random = _random.nextInt(3);
    double radius = random == 0
        ? r1 / 2
        : random == 1
            ? r2 / 2
            : r3 / 2;
    return radius;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  List<Widget> baseWidgets(Size biggest) {
    return [
      Positioned.fromRect(
        rect: Rect.fromCenter(center: radarCenter, width: r1, height: r1),
        child: AnimatedBuilder(
          animation: _rotationAnimation,
          builder: ((context, _) {
            return RotationTransition(
              turns: _rotationAnimation,
              child: SvgPicture.asset(
                AppImages.radar_background,
              ),
            );
          }),
        ),
      ),
      Positioned.fromRect(
        rect: Rect.fromCenter(center: radarCenter, width: r2, height: r2),
        child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, _) {
              return Opacity(
                opacity: _fadeAnimation.value * 0.9 + 0.1,
                child: SvgPicture.asset(
                  AppImages.highlighted_circle,
                ),
              );
            }),
      ),
      Positioned.fromRect(
        rect: Rect.fromCenter(center: radarCenter, width: r3, height: r3),
        child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, _) {
              return Opacity(
                opacity: (1 - _fadeAnimation.value) * 0.9 + 0.1,
                child: SvgPicture.asset(
                  AppImages.highlighted_circle,
                ),
              );
            }),
      ),
      Positioned.fromRect(
        rect: Rect.fromCenter(
            center: radarCenter, width: youSize, height: youSize),
        child: Image.asset(
          AppImages.you,
        ),
      ),
      DtrWidget(
          shouldTranslate: shouldTranslate,
          positionStart1: positionStart1,
          positionEnd1: positionEnd1,
          baseRect: biggest,
          controller: _controller),
      shouldTranslate
          ? DtrText(
              positionStart1: positionStart1,
              positionEnd1: positionEnd1,
              dtrSmallWidth: dtrSmallWidth,
              dtrBig: dtrBig,
              baseRect: biggest,
              controller: _controller,
              rotationAnimation: _rotationAnimation)
          : Container(),
      DtrWidget(
          shouldTranslate: shouldTranslate,
          positionStart1: positionStart2,
          positionEnd1: positionEnd2,
          baseRect: biggest,
          controller: _controller),
      shouldTranslate
          ? DtrText(
              positionStart1: positionStart2,
              positionEnd1: positionEnd2,
              dtrSmallWidth: dtrSmallWidth,
              dtrBig: dtrBig,
              baseRect: biggest,
              controller: _controller,
              rotationAnimation: _rotationAnimation)
          : Container(),
      DtrWidget(
          shouldTranslate: shouldTranslate,
          positionStart1: positionStart3,
          positionEnd1: positionEnd3,
          baseRect: biggest,
          controller: _controller),
      shouldTranslate
          ? DtrText(
              positionStart1: positionStart3,
              positionEnd1: positionEnd3,
              dtrSmallWidth: dtrSmallWidth,
              dtrBig: dtrBig,
              baseRect: biggest,
              controller: _controller,
              rotationAnimation: _rotationAnimation)
          : Container(),
      DtrWidget(
          shouldTranslate: shouldTranslate,
          positionStart1: positionStart4,
          positionEnd1: positionEnd4,
          baseRect: biggest,
          controller: _controller),
      shouldTranslate
          ? DtrText(
              positionStart1: positionStart4,
              positionEnd1: positionEnd4,
              dtrSmallWidth: dtrSmallWidth,
              dtrBig: dtrBig,
              baseRect: biggest,
              controller: _controller,
              rotationAnimation: _rotationAnimation)
          : Container(),
      Positioned(
        top: widget.screenHeight * 0.6,
        left: widget.screenWidth * 0.1,
        width: widget.screenWidth * 0.8,
        height: widget.screenHeight,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 1),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            margin: EdgeInsets.only(top: 30),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // if (_controller.isAnimating) {
        //   _controller.stop();
        // } else
        if (_controller.isCompleted) {
          _controller.reset();
        }
        _controller.forward();
        _fadeController.forward();
      },
      child: Container(
        child: LayoutBuilder(builder: (context, constraints) {
          final biggest = constraints.biggest;
          return Stack(children: baseWidgets(biggest) + widgets);
        }),
      ),
    );
  }
}

class DtrText extends StatelessWidget {
  const DtrText({
    Key? key,
    required this.positionStart1,
    required this.dtrSmallWidth,
    required this.baseRect,
    required this.positionEnd1,
    required this.dtrBig,
    required AnimationController controller,
    required Animation<double> rotationAnimation,
  })  : _controller = controller,
        _fadeAnimation = rotationAnimation,
        super(key: key);

  final Rect positionStart1;
  final double dtrSmallWidth;
  final Size baseRect;
  final Rect positionEnd1;
  final double dtrBig;
  final AnimationController _controller;
  final Animation<double> _fadeAnimation;

  @override
  Widget build(BuildContext context) {
    return PositionedTransition(
        rect: RelativeRectTween(
          begin: RelativeRect.fromSize(
              positionStart1.translate(dtrSmallWidth, 0), baseRect),
          end: RelativeRect.fromSize(
              positionEnd1.translate(dtrBig / 2, 0), baseRect),
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear)),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Text(
              'test',
              style: TextStyles.textStyle,
            ),
          ),
        ));
  }
}

class DtrWidget extends StatelessWidget {
  const DtrWidget({
    Key? key,
    required this.shouldTranslate,
    required this.positionStart1,
    required this.baseRect,
    required this.positionEnd1,
    required AnimationController controller,
  })  : _controller = controller,
        super(key: key);

  final bool shouldTranslate;
  final Rect positionStart1;
  final Size baseRect;
  final Rect positionEnd1;
  final AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    return shouldTranslate
        ? PositionedTransition(
            rect: RelativeRectTween(
              begin: RelativeRect.fromSize(positionStart1, baseRect),
              end: RelativeRect.fromSize(positionEnd1, baseRect),
            ).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeIn)),
            child: Image.asset(
              AppImages.dtr,
            ),
          )
        : Positioned.fromRect(
            rect: positionStart1,
            child: FadeTransition(
              opacity:
                  CurvedAnimation(parent: _controller, curve: Curves.easeIn),
              child: Image.asset(
                AppImages.dtr,
              ),
            ),
          );
  }
}

Widget getDtrWidget(Rect positionEnd) {
  return Positioned.fromRect(
    rect: positionEnd,
    child: Image.asset(
      AppImages.dtr,
    ),
  );
}

Widget getTextWidget(Rect positionEnd, double offsetX) {
  return Positioned.fromRect(
    rect: positionEnd.translate(offsetX, 0),
    child: Center(
      child: Text(
        'test',
        style: TextStyles.textStyle,
      ),
    ),
  );
}
