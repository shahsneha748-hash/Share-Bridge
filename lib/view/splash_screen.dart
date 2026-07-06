import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class CurtainClipper extends CustomClipper<Rect> {
  final double progress;

  CurtainClipper(this.progress);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(
      0,
      0,
      size.width * progress,
      size.height,
    );
  }

  @override
  bool shouldReclip(CurtainClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _controller;

  late Animation<Offset> _leftAnimation;
  late Animation<Offset> _rightAnimation;
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;
  late Animation<double> _bridgeReveal;
  late Animation<double> _humanPop;
  late Animation<double> _humanOpacity;
  late Animation<double> _heartPop;
  late Animation<double> _heartOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _leftAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    _rightAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(
      begin: 0.5,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.elasticOut),
      ),
    );

    _textOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0),
      ),
    );

    _bridgeReveal = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeInOut),
      ),
    );

    _humanPop = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    _humanOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );

    _heartPop = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.6, curve: Curves.elasticOut),
      ),
    );

    _heartOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () async {
      final user = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ScaleTransition(
          scale: _logoScale,
          child: SizedBox(
            width: 250,
            height: 290,
            child: Stack(
              alignment: Alignment.center,
              children: [

                FadeTransition(
                  opacity: _humanOpacity,
                  child: ScaleTransition(
                    scale: _humanPop,
                    child: Align(
                      alignment: const Alignment(-0.47, 0),
                      child: Image.asset(
                        "assets/images/left_human.png",
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                /// Left Logo Part
                // SlideTransition(
                //   position: _leftAnimation,
                //   child: Align(
                //     alignment: const Alignment(-0.47, 0),
                //     child: Image.asset(
                //       "assets/images/left_human.png",
                //       width: 150,
                //       height: 150,
                //       fit: BoxFit.contain,
                //     ),
                //   ),
                // ),

                FadeTransition(
                  opacity: _humanOpacity,
                  child: ScaleTransition(
                    scale: _humanPop,
                    child: Align(
                      alignment: const Alignment(0.47, 0),
                      child: Image.asset(
                        "assets/images/right_human.png",
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // /// Right Logo Part
                // SlideTransition(
                //   position: _rightAnimation,
                //   child: Align(
                //     alignment: const Alignment(0.47, 0),
                //     child: Image.asset(
                //       "assets/images/right_human.png",
                //       width: 150,
                //       height: 150,
                //       fit: BoxFit.contain,
                //     ),
                //   ),
                // ),

                Positioned(
                  bottom: 115, // adjust to match your design
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _heartOpacity,
                    child: ScaleTransition(
                      alignment: Alignment.center,
                      scale: _heartPop,
                      child: Image.asset(
                        "assets/images/heart1.png",
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Positioned(
                //   bottom: 105,
                //   child: Image.asset(
                //     "assets/images/logo 1.png",
                //     width: 60,
                //     height: 60,
                //     fit: BoxFit.contain,
                //   ),
                // ),

                /// Bridge Arc
                Positioned(
                  bottom: 75,
                  child: AnimatedBuilder(
                    animation: _bridgeReveal,
                    builder: (context, child) {
                      return ClipRect(
                        clipper: CurtainClipper(_bridgeReveal.value),
                        child: child,
                      );
                    },
                    child: Image.asset(
                      "assets/images/bridge.png",
                      width: 170,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                /// ShareBridge Text directly below arc
                Positioned(
                  bottom: 35, // adjust to sit under arc
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: const Text(
                      "ShareBridge",
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff174c35),
                      ),
                    ),
                  ),
                ),

                /// Tagline just below ShareBridge
                Positioned(
                  bottom: 18, // closer to ShareBridge
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: const Text(
                      "Together We Can",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xff7a8c34),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F5EE),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            buildAnimatedLogo(),
          ],
        ),
      ),
    );
  }
}