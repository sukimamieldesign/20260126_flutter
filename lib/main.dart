import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const JustOneSecondApp());
}

class JustOneSecondApp extends StatelessWidget {
  const JustOneSecondApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Just 1 Second',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  double _elapsedSeconds = 0.0;
  bool _isRunning = false;
  String _message = 'Tap to Start!';
  Color _messageColor = Colors.white70;

  int _consecutiveSuccess = 0;
  int _consecutiveFailure = 0;
  bool _isGameOver = false;
  bool _isHallOfFame = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isGameOver || _isHallOfFame) return;

    setState(() {
      _isRunning = true;
      _message = 'Stop at 1.00s!';
      _messageColor = Colors.white;
      _stopwatch.reset();
      _stopwatch.start();
    });

    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _elapsedSeconds = _stopwatch.elapsedMilliseconds / 1000.0;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _stopwatch.stop();

    double result = _stopwatch.elapsedMilliseconds / 1000.0;
    bool isSuccess = result >= 0.9 && result <= 1.1;

    setState(() {
      _isRunning = false;
      _elapsedSeconds = result;

      if (isSuccess) {
        _consecutiveSuccess++;
        _consecutiveFailure = 0;
        _message = 'SUCCESS! 🎉';
        _messageColor = Colors.greenAccent;
        _animationController.forward(from: 0.0);

        if (_consecutiveSuccess >= 3) {
          _isHallOfFame = true;
          _message = 'Congratulations!';
          _messageColor = Colors.amber;
          // パーティクルアニメーション開始
          _particleController.forward(from: 0.0);
        }
      } else {
        _consecutiveFailure++;
        _consecutiveSuccess = 0;
        _message = 'FAILED... 💀';
        _messageColor = Colors.redAccent;

        if (_consecutiveFailure >= 3) {
          _isGameOver = true;
          _message = 'GAME OVER 👻';
        }
      }
    });
  }

  void _resetGame() {
    setState(() {
      _stopwatch.reset();
      _elapsedSeconds = 0.0;
      _isRunning = false;
      _message = 'Tap to Start!';
      _messageColor = Colors.white70;
      _consecutiveSuccess = 0;
      _consecutiveFailure = 0;
      _isGameOver = false;
      _isHallOfFame = false;
      _particleController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isHallOfFame
                ? [
                    const Color(0xFF2D1B00),
                    const Color(0xFF4A3100),
                    const Color(0xFF3D2817),
                  ]
                : [
                    const Color(0xFF0F2027),
                    const Color(0xFF203A43),
                    const Color(0xFF2C5364),
                  ],
          ),
        ),
        child: Stack(
          children: [
            // パーティクルエフェクト（HALL OF FAME時のみ）
            if (_isHallOfFame)
              ParticleWidget(animation: _particleController),

            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildStopwatchDisplay(),
                      const SizedBox(height: 30),
                      _buildMessage(),
                      const SizedBox(height: 40),
                      _buildActionButton(),
                      const SizedBox(height: 30),
                      _buildStatusTrackers(),
                      if (_isGameOver || _isHallOfFame) ...[
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: _resetGame,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.15),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 8,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'JUST 1 SECOND',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            color: Colors.white.withOpacity(0.9),
            shadows: [
              Shadow(
                  blurRadius: 10,
                  color: Colors.blueAccent.withOpacity(0.5),
                  offset: const Offset(0, 4))
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Stop exactly at 1.00s',
          style: TextStyle(color: Colors.white54, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildStopwatchDisplay() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
          border: Border.all(
            color: _isRunning
                ? Colors.blueAccent
                : (_messageColor == Colors.white70
                    ? Colors.white24
                    : _messageColor),
            width: 8,
          ),
          boxShadow: [
            BoxShadow(
              color: (_isRunning ? Colors.blueAccent : _messageColor)
                  .withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 5,
            )
          ],
        ),
        child: Center(
          child: Text(
            _elapsedSeconds.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w200,
              fontVariations: [const FontVariation('wght', 200)],
              color: Colors.white,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _isHallOfFame
          ? ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0)
                  .animate(_particleController),
              child: Text(
                _message,
                key: ValueKey(_message),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _messageColor,
                  shadows: [
                    Shadow(
                      blurRadius: 20,
                      color: _messageColor.withOpacity(0.6),
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            )
          : Text(
              _message,
              key: ValueKey(_message),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _messageColor,
              ),
            ),
    );
  }

  Widget _buildActionButton() {
    if (_isGameOver || _isHallOfFame) return const SizedBox.shrink();

    return GestureDetector(
      onTapDown: (_) => _isRunning ? _stopTimer() : _startTimer(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: LinearGradient(
            colors: _isRunning
                ? [Colors.redAccent, Colors.orangeAccent]
                : [Colors.blueAccent, Colors.cyanAccent],
          ),
          boxShadow: [
            BoxShadow(
              color: (_isRunning ? Colors.redAccent : Colors.blueAccent)
                  .withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Text(
          _isRunning ? 'STOP' : 'START',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTrackers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCounterCard(
            'Success', _consecutiveSuccess, Colors.greenAccent, Icons.stars),
        const SizedBox(width: 20),
        _buildCounterCard(
            'Failure', _consecutiveFailure, Colors.redAccent, Icons.heart_broken),
      ],
    );
  }

  Widget _buildCounterCard(
      String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
        ],
      ),
    );
  }
}

/// パーティクルエフェクト（紙吹雪）
class ParticleWidget extends StatefulWidget {
  final Animation<double> animation;

  const ParticleWidget({
    required this.animation,
    super.key,
  });

  @override
  State<ParticleWidget> createState() => _ParticleWidgetState();
}

class _ParticleWidgetState extends State<ParticleWidget> {
  late List<Particle> particles;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _generateParticles();
  }

  void _generateParticles() {
    particles = List.generate(50, (_) {
      return Particle(
        x: random.nextDouble(),
        y: -0.2,
        vx: (random.nextDouble() - 0.5) * 0.5,
        vy: random.nextDouble() * 0.3 + 0.2,
        size: random.nextDouble() * 8 + 4,
        rotation: random.nextDouble() * 360,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(particles, widget.animation.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  final double vx;
  final double vy;
  final double size;
  double rotation;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.rotation,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.amber.withOpacity(1.0 - progress);

    for (var particle in particles) {
      // 位置更新
      particle.x += particle.vx * progress;
      particle.y += particle.vy * progress;
      particle.rotation += 5;

      if (particle.y < 1.2) {
        final x = particle.x * size.width;
        final y = particle.y * size.height;

        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(particle.rotation * pi / 180);

        // 四角形として描画
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size,
          ),
          paint,
        );

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
