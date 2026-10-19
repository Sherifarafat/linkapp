import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../app/widgets/network_alert.dart';
import '../../../auth/data/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onAuthenticated});

  final VoidCallback onAuthenticated;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  int _wordIndex = 0;

  static const _words = ['Share', 'Connect', 'Grow', 'Discover'];
  static const _arabicWords = ['شارك', 'تواصل', 'انمُ', 'اكتشف'];

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  Timer? _wordTimer;

  @override
  void initState() {
    super.initState();
    _wordTimer = Timer.periodic(const Duration(milliseconds: 2400), (_) {
      if (mounted) setState(() => _wordIndex = (_wordIndex + 1) % 4);
    });
  }

  @override
  void dispose() {
    _wordTimer?.cancel();
    super.dispose();
  }

  Future<void> _onGooglePressed() async {
    // Let the web preview continue into the app without Firebase Web setup.
    // Release builds and native platforms always use real Google sign-in.
    if (kDebugMode && kIsWeb) {
      widget.onAuthenticated();
      return;
    }
    await _signIn(_authService.signInWithGoogle);
  }

  Future<void> _signIn(Future<UserCredential> Function() action) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await action();
      if (mounted) widget.onAuthenticated();
    } on FirebaseAuthException catch (error) {
      if (_isNetworkFailure(error.code)) {
        _showNetworkAlert();
      } else {
        _showMessage(_firebaseMessage(error));
      }
    } on AuthException catch (error) {
      _showMessage(_isArabic
          ? (kIsWeb
              ? 'تسجيل الدخول من الويب محتاج تسجيل تطبيق Web في Firebase.'
              : 'Firebase غير مهيأ للمنصة الحالية.')
          : error.message);
    } catch (error) {
      if (error is SignInWithAppleAuthorizationException &&
          error.code == AuthorizationErrorCode.canceled) {
        return;
      }
      if (_isNetworkFailure('$error')) {
        _showNetworkAlert();
      } else {
        _showMessage(_isArabic
            ? 'حصلت مشكلة أثناء تسجيل الدخول. راجع إعدادات Firebase.'
            : 'Sign-in failed. Check the Firebase provider setup and try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _firebaseMessage(FirebaseAuthException error) {
    if (error.code == 'account-exists-with-different-credential') {
      return _isArabic
          ? 'الحساب موجود بطريقة تسجيل دخول مختلفة.'
          : 'This account already exists with a different sign-in method.';
    }
    return _isArabic
        ? 'تعذر تسجيل الدخول. تأكد من تفعيل الطريقة في Firebase.'
        : 'Could not sign in. Make sure this provider is enabled in Firebase.';
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isNetworkFailure(String value) {
    final normalized = value.toLowerCase();
    return normalized.contains('network-request-failed') ||
        normalized.contains('network error') ||
        normalized.contains('socketexception') ||
        normalized.contains('failed host lookup') ||
        normalized.contains('network is unreachable') ||
        normalized.contains('connection timed out');
  }

  void _showNetworkAlert() {
    if (!mounted) return;
    unawaited(NetworkAlert.show(context, isArabic: _isArabic));
  }

  void _showTour() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TourSheet(isArabic: _isArabic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? const Color(0xFF111111) : const Color(0xFFF7F7F7);
    final muted = isDark ? const Color(0xFF9A9A9A) : const Color(0xFF66666E);
    final white = isDark ? const Color(0xFFF7F7F7) : const Color(0xFF171719);
    final isArabic = _isArabic;
    final words = isArabic ? _arabicWords : _words;
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF03040A) : const Color(0xFFF8F8FA),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: _SpaceBackdrop(
              color: Theme.of(context).colorScheme.primary,
              lightBackground: !isDark,
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: SizedBox(
                  height: math.max(constraints.maxHeight, 540.0).toDouble(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: SizedBox.expand(
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: isDark ? white : background,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.link_rounded,
                                        size: 18,
                                        color: isDark ? background : white),
                                  ),
                                ),
                              ),
                              Center(
                                child: Directionality(
                                  textDirection: textDirection,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              isArabic ? 'خلّيك' : 'Let’s',
                                              style: TextStyle(
                                                color: white,
                                                fontSize: 36,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -1.1,
                                              ),
                                            ),
                                            const SizedBox(width: 9),
                                            AnimatedSize(
                                              duration: const Duration(milliseconds: 300),
                                              curve: Curves.easeOutCubic,
                                              alignment: Alignment.centerLeft,
                                              child: AnimatedSwitcher(
                                                duration: const Duration(milliseconds: 450),
                                                switchInCurve: Curves.easeOutCubic,
                                                switchOutCurve: Curves.easeInCubic,
                                                transitionBuilder: (child, animation) =>
                                                    FadeTransition(
                                                  opacity: animation,
                                                  child: SlideTransition(
                                                    position: Tween<Offset>(
                                                      begin: const Offset(0, .35),
                                                      end: Offset.zero,
                                                    ).animate(animation),
                                                    child: child,
                                                  ),
                                                ),
                                                child: Text(
                                                  words[_wordIndex],
                                                  key: ValueKey(words[_wordIndex]),
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    color: white,
                                                    fontSize: 36,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: -1.1,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      SizedBox(
                                        width: 214,
                                        child: _GlowTourButton(
                                          label: isArabic ? 'جولة سريعة' : 'Take tour',
                                          onTap: _showTour,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _ProviderButton(
                                      label: isArabic
                                          ? 'المتابعة باستخدام Google'
                                          : 'Continue with Google',
                                      onPressed: _isLoading ? null : _onGooglePressed,
                                      isLoading: _isLoading,
                                      leading: const _GoogleMark(),
                                      background: white,
                                      foreground: background,
                                      border: Colors.transparent,
                                    ),
                                    const SizedBox(height: 12),
                                    _ProviderButton(
                                      label: isArabic
                                          ? 'المتابعة باستخدام Apple'
                                          : 'Continue with Apple',
                                      onPressed: _isLoading
                                          ? null
                                          : () => _signIn(_authService.signInWithApple),
                                      isLoading: _isLoading,
                                      leading: const Icon(Icons.apple, size: 23),
                                      background: isDark
                                          ? const Color(0xFF303033)
                                          : const Color(0xFFE7E7EB),
                                      foreground: white,
                                      border: Colors.transparent,
                                    ),
                                    const SizedBox(height: 22),
                                    Text(
                                      isArabic
                                          ? 'بالمتابعة، أنت توافق على سياسة الخصوصية وشروط الاستخدام.'
                                          : 'By continuing, you agree to our Privacy Policy and Terms and Conditions.',
                                      textAlign: TextAlign.center,
                                      textDirection: textDirection,
                                      style: TextStyle(
                                        color: muted,
                                        fontSize: 12,
                                        height: 1.45,
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
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpaceBackdrop extends StatefulWidget {
  const _SpaceBackdrop({
    required this.color,
    this.blackBackground = false,
    this.lightBackground = false,
  });

  final Color color;
  final bool blackBackground;
  final bool lightBackground;

  @override
  State<_SpaceBackdrop> createState() => _SpaceBackdropState();
}

class _SpaceBackdropState extends State<_SpaceBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _SpacePainter(
          animation: _motion,
          accent: widget.color,
          blackBackground: widget.blackBackground,
          lightBackground: widget.lightBackground,
        ),
        size: Size.infinite,
      );
}

class _SpacePainter extends CustomPainter {
  _SpacePainter({
    required this.animation,
    required this.accent,
    required this.blackBackground,
    required this.lightBackground,
  })
      : super(repaint: animation);

  final Animation<double> animation;
  final Color accent;
  final bool blackBackground;
  final bool lightBackground;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = animation.value * math.pi * 2;
    final bounds = Offset.zero & size;
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: lightBackground
              ? const [Color(0xFFF8F9FC), Color(0xFFEFF2F8), Color(0xFFFAFAFC)]
              : blackBackground
                  ? const [Colors.black, Colors.black, Colors.black]
                  : const [Color(0xFF04050D), Color(0xFF010208), Color(0xFF03030C)],
        ).createShader(bounds),
    );

    _drawCloud(
      canvas,
      size,
      Offset(.13 + .17 * math.sin(phase), .39 + .16 * math.cos(phase)),
      size.longestSide * .78,
      lightBackground ? .07 : .17,
    );
    _drawCloud(
      canvas,
      size,
      Offset(.91 + .17 * math.cos(phase + 1.4), .72 + .16 * math.sin(phase)),
      size.longestSide * .68,
      lightBackground ? .055 : .14,
    );
    _drawCloud(
      canvas,
      size,
      Offset(.53 + .15 * math.sin(phase + 2.1), .11 + .13 * math.cos(phase)),
      size.longestSide * .53,
      lightBackground ? .04 : .09,
    );
  }

  void _drawCloud(
    Canvas canvas,
    Size size,
    Offset normalizedCenter,
    double radius,
    double opacity,
  ) {
    final center = Offset(
      size.width * normalizedCenter.dx,
      size.height * normalizedCenter.dy,
    );
    final rect = Rect.fromCircle(center: center, radius: radius);
    final shader = RadialGradient(
      colors: [
        accent.withValues(alpha: opacity),
        accent.withValues(alpha: opacity * .55),
        accent.withValues(alpha: opacity * .20),
        Colors.transparent,
      ],
      stops: const [0, .25, .58, 1],
    ).createShader(rect);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = shader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28)
        ..blendMode = BlendMode.screen,
    );
  }

  @override
  bool shouldRepaint(covariant _SpacePainter oldDelegate) =>
      oldDelegate.accent != accent ||
      oldDelegate.animation != animation ||
      oldDelegate.blackBackground != blackBackground ||
      oldDelegate.lightBackground != lightBackground;
}

class _GlowTourButton extends StatefulWidget {
  const _GlowTourButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_GlowTourButton> createState() => _GlowTourButtonState();
}

class _GlowTourButtonState extends State<_GlowTourButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = isDark ? const Color(0xFF020205) : Colors.white;
    final textColor = isDark ? const Color(0xFFF5F3FF) : const Color(0xFF171719);
    return Semantics(
        button: true,
        label: widget.label,
        child: GestureDetector(
          onTap: widget.onTap,
          child: SizedBox(
            height: 66,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  child: Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -.2,
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: CustomPaint(painter: _GlowBorderPainter(_glow)),
                ),
              ],
            ),
          ),
        ),
      );
  }
}

class _GlowBorderPainter extends CustomPainter {
  _GlowBorderPainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(7, 8, size.width - 14, size.height - 16);
    final shape = RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2));
    final gradient = SweepGradient(
      transform: GradientRotation(animation.value * math.pi * 2),
      colors: const [
        Color(0xFF271BFF),
        Color(0xFF4932FF),
        Color(0xFFB7B4FF),
        Color(0xFFF8F5FF),
        Color(0xFFD02CFF),
        Color(0xFF5430FF),
        Color(0xFF271BFF),
      ],
      stops: const [0, .25, .42, .49, .57, .76, 1],
    ).createShader(rect);

    canvas.drawRRect(
      shape,
      Paint()
        ..shader = gradient
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawRRect(
      shape,
      Paint()
        ..shader = gradient
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.15
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant _GlowBorderPainter oldDelegate) =>
      oldDelegate.animation != animation;
}

class _TourSheet extends StatefulWidget {
  const _TourSheet({required this.isArabic});

  final bool isArabic;

  @override
  State<_TourSheet> createState() => _TourSheetState();
}

class _TourSheetState extends State<_TourSheet> {
  final PageController _controller = PageController();
  final FlutterTts _tts = FlutterTts();
  Timer? _typingTimer;
  Timer? _speechRevealTimer;
  Timer? _advanceTimer;
  int _page = 0;
  int _visibleChars = 0;
  int _speechTargetChars = 0;
  int _runId = 0;
  bool _voiceEnabled = true;
  bool _isOpening = true;
  bool _hasSpeechProgress = false;
  bool _isSpeaking = false;

  static const _steps = [
    _TourStep(
      title: 'One link Everything you are',
      description: 'Bring your socials, videos, and favorite places together on one page',
    ),
    _TourStep(
      title: 'Make your page yours',
      description: 'Choose your look, add content, and shape a page that feels like you',
    ),
    _TourStep(
      title: 'Share it Grow from there',
      description: 'Post one simple link so people can find everything you create',
    ),
    _TourStep(
      title: 'Turn your page into a shop',
      description: 'Showcase your products in a catalog and make it easy to shop',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _typingTimer?.cancel();
    _speechRevealTimer?.cancel();
    _advanceTimer?.cancel();
    _runId++;
    unawaited(_safeStop());
    super.dispose();
  }

  String _narrationFor(_TourStep step) => '${step.title} ${step.description}';

  void _handlePageChanged(int index) {
    _advanceTimer?.cancel();
    setState(() => _page = index);
    unawaited(_playStep(index));
  }

  void _finishOpening() {
    if (!mounted || !_isOpening) return;
    setState(() => _isOpening = false);
    unawaited(_playStep(0));
  }

  Future<void> _safeStop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Keep the visual tour usable if this device has no speech engine.
    }
  }

  Future<void> _selectNaturalEnglishVoice() async {
    try {
      final voices = await _tts.getVoices;
      if (voices is! List) return;

      final englishVoices = voices.whereType<Map>().where((voice) {
        final locale = '${voice['locale'] ?? ''}'.replaceAll('_', '-').toLowerCase();
        return locale == 'en-us' || locale.startsWith('en-us-');
      }).toList();
      final femaleVoice = englishVoices.cast<Map>().firstWhere(
        (voice) {
          final gender = '${voice['gender'] ?? ''}'.toLowerCase();
          final voiceId = '${voice['identifier'] ?? ''}'.toLowerCase();
          final name = '${voice['name'] ?? ''}'.toLowerCase();
          return gender == 'female' ||
              voiceId.contains('female') ||
              name.contains('female');
        },
        orElse: () => <String, dynamic>{},
      );
      if (femaleVoice.isNotEmpty && femaleVoice['name'] != null) {
        final voice = <String, String>{
          'name': '${femaleVoice['name']}',
          'locale': '${femaleVoice['locale'] ?? 'en-US'}',
        };
        if (femaleVoice['identifier'] != null) {
          voice['identifier'] = '${femaleVoice['identifier']}';
        }
        await _tts.setVoice(voice);
      }
    } catch (_) {
      // Keep the device's default English voice if voice discovery is unavailable.
    }
  }

  Future<void> _playStep(int index) async {
    final run = ++_runId;
    _typingTimer?.cancel();
    _speechRevealTimer?.cancel();
    _advanceTimer?.cancel();
    _hasSpeechProgress = false;
    _speechTargetChars = 0;
    await _safeStop();
    if (!mounted || run != _runId) return;

    final narration = _narrationFor(_steps[index]);
    setState(() {
      _visibleChars = 0;
      _isSpeaking = false;
    });

    Timer(const Duration(milliseconds: 350), () {
      if (mounted && run == _runId && !_hasSpeechProgress) {
        _startTypewriter(run, narration.length);
      }
    });

    if (!_voiceEnabled) return;
    try {
      await _tts.setLanguage('en-US');
      await _selectNaturalEnglishVoice();
      await _tts.setSpeechRate(.82);
      await _tts.setPitch(1.1);
      if (!mounted || run != _runId) return;
      _tts.setStartHandler(() {
        if (mounted && run == _runId) setState(() => _isSpeaking = true);
      });
      _tts.setProgressHandler((text, startOffset, endOffset, word) {
        if (!mounted || run != _runId) return;
        _hasSpeechProgress = true;
        _typingTimer?.cancel();
        final visible = endOffset.clamp(0, narration.length).toInt();
        _speechTargetChars = math.max(_speechTargetChars, visible);
        _revealSpeechText(run);
      });
      _tts.setCompletionHandler(() {
        if (!mounted || run != _runId) return;
        _typingTimer?.cancel();
        _speechRevealTimer?.cancel();
        setState(() {
          _isSpeaking = false;
          _visibleChars = narration.length;
        });
        if (index < _steps.length - 1) {
          _advanceTimer = Timer(const Duration(milliseconds: 700), () {
            if (!mounted || run != _runId || index != _page) return;
            _controller.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
            );
          });
        }
      });
      _tts.setErrorHandler((message) {
        if (!mounted || run != _runId) return;
        _speechRevealTimer?.cancel();
        setState(() => _isSpeaking = false);
        _hasSpeechProgress = false;
        _startTypewriter(run, narration.length);
      });
      await _tts.speak(narration);
    } catch (_) {
      if (mounted && run == _runId) {
        setState(() => _isSpeaking = false);
        _hasSpeechProgress = false;
        _startTypewriter(run, narration.length);
      }
    }
  }

  void _revealSpeechText(int run) {
    if (_speechTargetChars <= _visibleChars ||
        _speechRevealTimer?.isActive == true) {
      return;
    }
    _speechRevealTimer = Timer.periodic(const Duration(milliseconds: 24), (timer) {
      if (!mounted || run != _runId) {
        timer.cancel();
        return;
      }
      if (_visibleChars >= _speechTargetChars) {
        timer.cancel();
        return;
      }
      setState(() => _visibleChars++);
    });
  }

  void _startTypewriter(int run, int length) {
    if (_typingTimer?.isActive == true) return;
    _typingTimer = Timer.periodic(const Duration(milliseconds: 42), (timer) {
      if (!mounted || run != _runId || _hasSpeechProgress) {
        timer.cancel();
        return;
      }
      if (_visibleChars >= length) {
        timer.cancel();
        return;
      }
      setState(() => _visibleChars++);
    });
  }

  Future<void> _toggleVoice() async {
    setState(() => _voiceEnabled = !_voiceEnabled);
    if (_voiceEnabled) {
      await _playStep(_page);
      return;
    }
    final run = ++_runId;
    _typingTimer?.cancel();
    _speechRevealTimer?.cancel();
    _hasSpeechProgress = false;
    await _safeStop();
    if (!mounted || run != _runId) return;
    setState(() => _isSpeaking = false);
    _startTypewriter(run, _narrationFor(_steps[_page]).length);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = colors.onSurface;
    final secondaryForeground = foreground.withValues(alpha: isDark ? .72 : .76);
    final step = _steps[_page];
    final narration = _narrationFor(step);
    final visible = narration.substring(
      0,
      _visibleChars.clamp(0, narration.length).toInt(),
    );
    final titleEnd = visible.length.clamp(0, step.title.length).toInt();
    final descriptionStart = step.title.length + 1;
    final descriptionStartInVisible =
        math.min(descriptionStart, visible.length).toInt();
    final typedTitle = visible.substring(0, titleEnd);
    final typedDescription = visible.substring(descriptionStartInVisible);

    return FractionallySizedBox(
      heightFactor: .85,
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: _SpaceBackdrop(
                color: colors.primary,
                blackBackground: true,
                lightBackground: !isDark,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? const [Color(0x33000000), Color(0xB2000000)]
                          : const [Color(0x0FFFFFFF), Color(0x22FFFFFF)],
                    ),
                  ),
                ),
              ),
            ),
            if (_isOpening)
              Positioned.fill(
                child: _TourOpening(
                  isArabic: widget.isArabic,
                  accent: colors.primary,
                  onComplete: _finishOpening,
                ),
              )
            else
              SafeArea(
                top: false,
                child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 44,
                          child: IconButton(
                            tooltip: widget.isArabic ? 'إغلاق الجولة' : 'Close tour',
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                            color: foreground.withValues(alpha: .78),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 38,
                          height: 4,
                          decoration: BoxDecoration(
                            color: foreground.withValues(alpha: .28),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: _steps.length,
                        onPageChanged: _handlePageChanged,
                        itemBuilder: (context, index) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 210,
                              child: _TourArtwork(
                                key: ValueKey('artwork-$index'),
                                index: index,
                                accent: colors.primary,
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 112,
                              child: Center(
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: typedTitle,
                                        style: TextStyle(
                                          color: foreground,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          height: 1.35,
                                        ),
                                      ),
                                      if (visible.length > step.title.length)
                                        TextSpan(
                                          text: '\n$typedDescription',
                                          style: TextStyle(
                                            color: secondaryForeground,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                            height: 1.5,
                                          ),
                                        ),
                                      if (_isSpeaking)
                                        TextSpan(
                                          text: '  •',
                                          style: TextStyle(
                                            color: colors.primary,
                                            fontSize: 20,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(
                              _steps.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 240),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: index == _page ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: index == _page
                                      ? colors.primary
                                      : foreground.withValues(alpha: .24),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: () {
                              if (_page == _steps.length - 1) {
                                Navigator.of(context).pop();
                              } else {
                                _controller.nextPage(
                                  duration: const Duration(milliseconds: 480),
                                  curve: Curves.easeInOutCubic,
                                );
                              }
                            },
                            icon: Icon(
                              _page == _steps.length - 1
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                            label: Text(
                              _page == _steps.length - 1
                                  ? (widget.isArabic ? 'ابدأ' : 'Let’s go')
                                  : (widget.isArabic ? 'التالي' : 'Next'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TourOpening extends StatefulWidget {
  const _TourOpening({
    required this.isArabic,
    required this.accent,
    required this.onComplete,
  });

  final bool isArabic;
  final Color accent;
  final VoidCallback onComplete;

  @override
  State<_TourOpening> createState() => _TourOpeningState();
}

class _TourOpeningState extends State<_TourOpening>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onComplete();
    });

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = Theme.of(context).colorScheme.onSurface;
    final fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(.16, .42, curve: Curves.easeOut),
    );
    final fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(.88, 1, curve: Curves.easeIn),
      ),
    );

    return SafeArea(
      top: false,
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: 12,
            child: IconButton(
              tooltip: widget.isArabic ? 'إغلاق الجولة' : 'Close tour',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
              color: foreground.withValues(alpha: .78),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: fadeOut,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: 230,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final progress = _controller.value;
                        final scale =
                            .78 +
                            .22 *
                                Curves.easeOutBack.transform(
                                  (progress / .55).clamp(0, 1).toDouble(),
                                );
                        return Transform.scale(
                          scale: scale,
                          child: CustomPaint(
                            painter: _TourOpeningPainter(
                              progress: progress,
                              accent: widget.accent,
                            ),
                            child: Center(child: child),
                          ),
                        );
                      },
                      child: Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.accent,
                              Color.lerp(widget.accent, Colors.black, .22)!,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.accent.withValues(alpha: .45),
                              blurRadius: 40,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.link_rounded,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeTransition(
                    opacity: fadeIn,
                    child: Column(
                      children: [
                        Text(
                          'Link',
                          style: TextStyle(
                            color: foreground,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.isArabic
                              ? 'كل عالمك في رابط واحد'
                              : 'Your world in one link',
                          style: TextStyle(
                            color: foreground.withValues(
                              alpha: isDark ? .72 : .76,
                            ),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TourOpeningPainter extends CustomPainter {
  const _TourOpeningPainter({required this.progress, required this.accent});

  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final fade = (1 - progress * .45).clamp(.25, 1.0).toDouble();
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = accent.withValues(alpha: .32 * fade);
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..color = accent.withValues(alpha: .24 * fade);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * math.pi * 1.7);
    final firstOrbit = Rect.fromCenter(
      center: Offset.zero,
      width: 192,
      height: 78,
    );
    canvas.drawOval(firstOrbit, glowPaint);
    canvas.drawOval(firstOrbit, orbitPaint);

    canvas.rotate(-progress * math.pi * 3.1);
    final secondOrbit = Rect.fromCenter(
      center: Offset.zero,
      width: 166,
      height: 118,
    );
    canvas.drawOval(
      secondOrbit,
      orbitPaint..color = accent.withValues(alpha: .2 * fade),
    );

    final angle = progress * math.pi * 2.8;
    final satellite = Offset(math.cos(angle) * 96, math.sin(angle) * 39);
    canvas.drawCircle(
      satellite,
      7,
      Paint()
        ..color = accent.withValues(alpha: .25 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(
      satellite,
      3.5,
      Paint()..color = accent.withValues(alpha: fade),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TourOpeningPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.accent != accent;
}

class _TourStep {
  const _TourStep({required this.title, required this.description});

  final String title;
  final String description;
}

class _TourArtwork extends StatelessWidget {
  const _TourArtwork({super.key, required this.index, required this.accent});

  final int index;
  final Color accent;

  @override
  Widget build(BuildContext context) => Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: .88, end: 1).animate(animation),
              child: child,
            ),
          ),
          child: switch (index) {
            0 => _ProfileArtwork(key: const ValueKey(0), accent: accent),
            1 => _ContentArtwork(key: const ValueKey(1), accent: accent),
            2 => _GrowthArtwork(key: const ValueKey(2), accent: accent),
            _ => _CatalogArtwork(key: const ValueKey(3), accent: accent),
          },
        ),
      );
}

class _ProfileArtwork extends StatelessWidget {
  const _ProfileArtwork({super.key, required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : const Color(0xFF171719);
    final panel = isDark ? const Color(0xDD0B0C14) : Colors.white;
    return SizedBox(
        width: 250,
        height: 190,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 18,
              top: 28,
              child: _FloatingBadge(icon: Icons.camera_alt_rounded, accent: accent),
            ),
            Positioned(
              right: 16,
              bottom: 24,
              child: _FloatingBadge(icon: Icons.play_arrow_rounded, accent: accent),
            ),
            Container(
              width: 142,
              height: 184,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: foreground.withValues(alpha: .12)),
                boxShadow: [
                  BoxShadow(color: accent.withValues(alpha: .24), blurRadius: 32),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: accent.withValues(alpha: .28),
                    child: Icon(Icons.person_rounded, color: foreground),
                  ),
                  const SizedBox(height: 7),
                  Text('your.name', style: TextStyle(color: foreground, fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 9),
                  _MiniLink(label: 'Instagram', icon: Icons.camera_alt_rounded, accent: accent),
                  const SizedBox(height: 5),
                  _MiniLink(label: 'My website', icon: Icons.language_rounded, accent: accent),
                  const SizedBox(height: 5),
                  _MiniLink(label: 'Latest video', icon: Icons.play_circle_rounded, accent: accent),
                ],
              ),
            ),
          ],
        ),
      );
  }
}

class _MiniLink extends StatelessWidget {
  const _MiniLink({required this.label, required this.icon, required this.accent});
  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : const Color(0xFF171719);
    return Container(
        height: 25,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            Icon(icon, color: foreground, size: 11),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: foreground, fontSize: 8)),
            const Spacer(),
            Icon(
              Icons.arrow_outward_rounded,
              color: foreground.withValues(alpha: .54),
              size: 9,
            ),
          ],
        ),
      );
  }
}

class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge({required this.icon, required this.accent});
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : const Color(0xFF171719);
    final panel = isDark ? const Color(0xDD10121C) : Colors.white;
    return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: panel,
          shape: BoxShape.circle,
          border: Border.all(color: accent.withValues(alpha: .55)),
          boxShadow: [BoxShadow(color: accent.withValues(alpha: .22), blurRadius: 18)],
        ),
        child: Icon(icon, color: foreground, size: 19),
      );
  }
}

class _ContentArtwork extends StatelessWidget {
  const _ContentArtwork({super.key, required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : const Color(0xFF171719);
    final panel = isDark ? const Color(0xEE0B0C14) : Colors.white;
    const cards = [
      (Icons.photo_rounded, 'Photos'),
      (Icons.play_circle_fill_rounded, 'Videos'),
      (Icons.description_rounded, 'Files'),
      (Icons.shopping_bag_rounded, 'Shop'),
    ];
    return SizedBox(
      width: 252,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: 14,
            top: 14,
            child: Transform.rotate(
              angle: .12,
              child: Container(
                width: 200,
                height: 158,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
          Container(
            width: 218,
            height: 160,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: foreground.withValues(alpha: .12)),
              boxShadow: [BoxShadow(color: accent.withValues(alpha: .2), blurRadius: 30)],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Your content', style: TextStyle(color: foreground, fontSize: 13, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Icon(Icons.add_circle_rounded, color: accent, size: 18),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cards.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.4,
                    ),
                    itemBuilder: (context, index) => Container(
                      decoration: BoxDecoration(
                        color: foreground.withValues(alpha: .06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(cards[index].$1, color: accent, size: 15),
                          const SizedBox(width: 5),
                          Text(cards[index].$2, style: TextStyle(color: foreground, fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthArtwork extends StatelessWidget {
  const _GrowthArtwork({super.key, required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : const Color(0xFF171719);
    final panel = isDark ? const Color(0xEE0B0C14) : Colors.white;
    return SizedBox(
        width: 250,
        height: 190,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 14,
              bottom: 24,
              child: _FloatingBadge(icon: Icons.share_rounded, accent: accent),
            ),
            Positioned(
              right: 12,
              top: 20,
              child: _FloatingBadge(icon: Icons.favorite_rounded, accent: accent),
            ),
            Container(
              width: 218,
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: foreground.withValues(alpha: .12)),
                boxShadow: [BoxShadow(color: accent.withValues(alpha: .2), blurRadius: 30)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your audience', style: TextStyle(color: foreground.withValues(alpha: .68), fontSize: 10)),
                  const SizedBox(height: 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('1,248', style: TextStyle(color: foreground, fontSize: 23, fontWeight: FontWeight.w700)),
                      SizedBox(width: 7),
                      Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text('+18%', style: TextStyle(color: Color(0xFF62D891), fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: CustomPaint(
                      painter: _GrowthChartPainter(accent),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}

class _CatalogArtwork extends StatelessWidget {
  const _CatalogArtwork({super.key, required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : const Color(0xFF171719);
    final panel = isDark ? const Color(0xEE0B0C14) : Colors.white;
    const products = [
      (Icons.checkroom_rounded, 'Style'),
      (Icons.headphones_rounded, 'Audio'),
      (Icons.watch_rounded, 'Watches'),
      (Icons.backpack_rounded, 'Bags'),
    ];
    return SizedBox(
      width: 252,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 18,
            top: 16,
            child: _FloatingBadge(icon: Icons.shopping_bag_rounded, accent: accent),
          ),
          Container(
            width: 216,
            height: 166,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: foreground.withValues(alpha: .12)),
              boxShadow: [BoxShadow(color: accent.withValues(alpha: .22), blurRadius: 30)],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Product catalog', style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Icon(Icons.storefront_rounded, color: accent, size: 17),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 7,
                      crossAxisSpacing: 7,
                      childAspectRatio: 2.15,
                    ),
                    itemBuilder: (context, index) => Container(
                      decoration: BoxDecoration(
                        color: foreground.withValues(alpha: .06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(products[index].$1, color: accent, size: 15),
                          const SizedBox(width: 5),
                          Text(products[index].$2, style: TextStyle(color: foreground, fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthChartPainter extends CustomPainter {
  const _GrowthChartPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(0, size.height * .82),
      Offset(size.width * .18, size.height * .67),
      Offset(size.width * .34, size.height * .72),
      Offset(size.width * .5, size.height * .42),
      Offset(size.width * .68, size.height * .53),
      Offset(size.width * .84, size.height * .2),
      Offset(size.width, size.height * .08),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
    for (final point in points) {
      canvas.drawCircle(point, 2, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/icons/google_g_logo.png',
        width: 24,
        height: 24,
        fit: BoxFit.contain,
      );
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.leading,
    required this.background,
    required this.foreground,
    required this.border,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget leading;
  final Color background;
  final Color foreground;
  final Color border;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 54,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: background,
            foregroundColor: foreground,
            side: BorderSide(color: border),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 18),
          ),
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.3, color: foreground),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    leading,
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      );
}
