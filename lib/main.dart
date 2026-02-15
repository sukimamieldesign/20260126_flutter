import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB1q_juETj_iLKrawXmmH2F29hJiPG2-9k",
      appId: "1:280623038074:web:98acb8a11fd714578605c3",
      messagingSenderId: "280623038074",
      projectId: "flutter-7a989",
      authDomain: "flutter-7a989.firebaseapp.com",
      storageBucket: "flutter-7a989.firebasestorage.app",
    ),
  );
  
  runApp(const JustOneSecondApp());
}

class JustOneSecondApp extends StatelessWidget {
  const JustOneSecondApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Just 1 Second: Infinite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.orangeAccent,
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
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  double _elapsedSeconds = 0.0;
  bool _isRunning = false;
  String _message = 'Tap to Start!';
  Color _messageColor = Colors.white70;

  int _consecutiveSuccess = 0;
  int _personalBest = 0;
  String? _userId;
  bool _isGameOver = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _particleController;
  late AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // ユーザーIDの取得または生成
    String? userId = prefs.getString('user_id');
    if (userId == null) {
      userId = Uuid().v4();
      await prefs.setString('user_id', userId);
    }

    // 自己ベストの取得
    int pb = prefs.getInt('personal_best') ?? 0;

    setState(() {
      _userId = userId;
      _personalBest = pb;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _particleController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isGameOver) return;

    setState(() {
      _isRunning = true;
      _message = 'STOP AT 1.00s!';
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
        _message = 'SUCCESS! ${_consecutiveSuccess} COMBO';
        _messageColor = Colors.greenAccent;
        _animationController.forward(from: 0.0);
        _particleController.forward(from: 0.0);
        _bgAnimationController.forward(from: 0.0).then((_) => _bgAnimationController.reverse());
      } else {
        _isGameOver = true;
        _message = 'GAME OVER 💀';
        _messageColor = Colors.redAccent;
        
        _handleGameOver();
      }
    });
  }

  Future<void> _handleGameOver() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 自己ベスト更新チェック
    if (_consecutiveSuccess > _personalBest) {
      setState(() {
        _personalBest = _consecutiveSuccess;
      });
      await prefs.setInt('personal_best', _personalBest);
    }

    // Firebaseへログ送信
    _logHighScore(_consecutiveSuccess);
  }

  Future<void> _logHighScore(int score) async {
    // スコア0でもログに残したい場合はこのまま、1以上の時だけに絞るなら if (score > 0)
    print('Attempting to log score: $score');
    try {
      await FirebaseFirestore.instance.collection('game_sessions').add({
        'user_id': _userId, // 端末ごとのIDを付与
        'final_score': score,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'web', 
      }).timeout(const Duration(seconds: 10));
      print('✅ High score logged successfully');
    } catch (e) {
      print('❌ Error logging score: $e');
    }
  }

  void _resetGame() {
    setState(() {
      _stopwatch.reset();
      _elapsedSeconds = 0.0;
      _isRunning = false;
      _message = 'Ready? Go!';
      _messageColor = Colors.white70;
      _consecutiveSuccess = 0;
      _isGameOver = false;
      _particleController.reset();
      _bgAnimationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Layer
          _buildBackground(),
          
          // Particles
          if (_consecutiveSuccess > 0)
            ParticleWidget(animation: _particleController),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildScoreDisplay(),
                    const SizedBox(height: 40),
                    _buildStopwatchDisplay(),
                    const SizedBox(height: 30),
                    _buildMessage(),
                    const SizedBox(height: 50),
                    _buildActionButton(),
                    if (_isGameOver) ...[
                      const SizedBox(height: 40),
                      _buildGameOverUI(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _bgAnimationController,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Base Background
            Container(
              color: const Color(0xFF0F2027),
            ),
            // Success Image with Opacity
            if (_consecutiveSuccess > 0 && !_isGameOver)
              Opacity(
                opacity: _bgAnimationController.value * 0.8,
                child: Image.asset(
                  'assets/images/success_bg.png',
                  fit: BoxFit.cover,
                ),
              ),
            // Game Over Image
            if (_isGameOver)
              Image.asset(
                'assets/images/game_over_bg.png',
                fit: BoxFit.cover,
              ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScoreDisplay() {
    return Column(
      children: [
        Text(
          'COMBO',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white60,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '$_consecutiveSuccess',
          style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w900,
            color: Colors.orangeAccent,
            shadows: [
              Shadow(blurRadius: 20, color: Colors.orange.withOpacity(0.5)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'YOUR BEST: $_personalBest',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white38,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStopwatchDisplay() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (_isRunning ? Colors.blueAccent : _messageColor).withOpacity(0.3),
              blurRadius: 40,
              spreadRadius: 10,
            )
          ],
          border: Border.all(
            color: _isRunning ? Colors.blueAccent : _messageColor,
            width: 4,
          ),
        ),
        child: Center(
          child: Text(
            _elapsedSeconds.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return Text(
      _message,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: _messageColor,
      ),
    );
  }

  Widget _buildActionButton() {
    if (_isGameOver) return const SizedBox.shrink();

    return GestureDetector(
      onTapDown: (_) => _isRunning ? _stopTimer() : _startTimer(),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: _isRunning 
              ? [Colors.red, Colors.orange] 
              : [Colors.blueAccent, Colors.cyan],
          ),
          boxShadow: [
            BoxShadow(
              color: (_isRunning ? Colors.red : Colors.blue).withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Center(
          child: Text(
            _isRunning ? 'STOP' : 'START',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverUI() {
    return Column(
      children: [
        const Text(
          'FINAL SCORE',
          style: TextStyle(fontSize: 18, color: Colors.white70),
        ),
        Text(
          '$_consecutiveSuccess',
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.redAccent),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _resetGame,
          icon: const Icon(Icons.refresh),
          label: const Text('RETRY CHALLENGE'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white24,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ],
    );
  }
}

class ParticleWidget extends StatefulWidget {
  final Animation<double> animation;
  const ParticleWidget({required this.animation, super.key});

  @override
  State<ParticleWidget> createState() => _ParticleWidgetState();
}

class _ParticleWidgetState extends State<ParticleWidget> {
  late List<Particle> particles;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    particles = List.generate(40, (_) => Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      vx: (random.nextDouble() - 0.5) * 0.2,
      vy: (random.nextDouble() - 0.5) * 0.2,
      size: random.nextDouble() * 10 + 2,
    ));
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
  double x, y;
  final double vx, vy, size;
  Particle({required this.x, required this.y, required this.vx, required this.vy, required this.size});
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.orangeAccent.withOpacity(1.0 - progress);
    for (var p in particles) {
      canvas.drawCircle(Offset((p.x + p.vx * progress) * size.width, (p.y + p.vy * progress) * size.height), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
