// ============================================================
// Bagian Import Library
// ============================================================
// dart:async dipakai untuk Timer.
// dart:convert dipakai untuk encode/decode JSON high score.
// dart:math dipakai untuk Random dan mencari nilai max score sebelumnya.
import 'dart:async';
import 'dart:convert';
import 'dart:math';

// Flutter Material untuk semua komponen UI.
import 'package:flutter/material.dart';

// SharedPreferences untuk menyimpan username dan high score secara lokal.
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// Bagian Entry Point
// ============================================================
// Entry point aplikasi Flutter.
void main() {
  runApp(const MyApp());
}

// ============================================================
// Bagian Konfigurasi Global Aplikasi
// ============================================================
// Key SharedPreferences dan konfigurasi utama permainan.
const String _usernameKey = 'memorimage_username';
const String _highScoresKey = 'memorimage_high_scores';
const int _roundsPerGame = 5;
const int _memorizeSeconds = 3;
const int _answerSeconds = 30;

// ============================================================
// Bagian Root App dan Session User
// ============================================================
// Root aplikasi: mengatur session user dan screen awal.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _username;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  // SharedPreferences: membaca username yang tersimpan saat app dibuka.
  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }

    setState(() {
      _username = prefs.getString(_usernameKey);
      _isLoading = false;
    });
  }

  // SharedPreferences: menyimpan username agar user tetap login.
  Future<void> _login(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanedUsername = username.trim();
    await prefs.setString(_usernameKey, cleanedUsername);

    if (!mounted) {
      return;
    }

    setState(() {
      _username = cleanedUsername;
    });
  }

  // SharedPreferences: menghapus username saat user logout.
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);

    if (!mounted) {
      return;
    }

    setState(() {
      _username = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Routing awal:
    // 1. LoadingScreen saat app membaca storage.
    // 2. LoginScreen jika belum ada username.
    // 3. MainMenuScreen jika username sudah tersimpan.
    return MaterialApp(
      title: 'Memorimage',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: _isLoading
          ? const LoadingScreen()
          : _username == null
          ? LoginScreen(onLogin: _login)
          : MainMenuScreen(username: _username!, onLogout: _logout),
    );
  }
}

// ============================================================
// Bagian Theme / Tampilan Global
// ============================================================
// Theme aplikasi: warna, AppBar, button, dan input field.
ThemeData _buildTheme() {
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF087E8B),
        brightness: Brightness.light,
      ).copyWith(
        primary: const Color(0xFF087E8B),
        secondary: const Color(0xFFF4A261),
        tertiary: const Color(0xFFE76F51),
        surface: const Color(0xFFFFFBF5),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFFF7FAFA),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 0,
      titleTextStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(120, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(120, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.white,
    ),
  );
}

// ============================================================
// Bagian Loading Screen
// ============================================================
// Loading screen sementara saat app membaca session dari storage.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

// ============================================================
// Bagian Login Screen
// ============================================================
// Login screen: meminta username sebelum user masuk ke main menu.
class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.onLogin, super.key});

  final Future<void> Function(String username) onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // Validasi form login lalu panggil callback untuk menyimpan username.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await widget.onLogin(_usernameController.text);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          // SingleChildScrollView membuat login tetap aman di layar kecil.
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  // Form dipakai agar username bisa divalidasi sebelum disimpan.
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/memorimage/camera_blue.png',
                            width: 148,
                            height: 148,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Memorimage',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Masukkan username untuk mulai menyimpan skor.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        // Input username: wajib diisi, lalu disimpan ke storage.
                        TextFormField(
                          controller: _usernameController,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Username wajib diisi';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 18),
                        // Tombol login berubah menjadi loading saat proses simpan.
                        FilledButton.icon(
                          onPressed: _isSaving ? null : _submit,
                          icon: _isSaving
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.login),
                          label: const Text('Masuk'),
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
    );
  }
}

// ============================================================
// Bagian Main Menu
// ============================================================
// Main menu: halaman utama setelah login.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({
    required this.username,
    required this.onLogout,
    super.key,
  });

  final String username;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memorimage')),
      // Drawer berisi username, menu high score, dan logout.
      drawer: _MainDrawer(username: username, onLogout: onLogout),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Wrap(
                  spacing: 24,
                  runSpacing: 20,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Image.asset(
                      'assets/memorimage/pencil_green.png',
                      width: 168,
                      height: 168,
                    ),
                    SizedBox(
                      width: 500,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, $username',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ingat 5 gambar yang muncul bergantian. Setelah itu, pilih gambar yang sama dari 4 opsi. Setiap jawaban benar bernilai sisa waktu pada timer.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                _InfoStrip(
                  icon: Icons.visibility,
                  title: 'Fase ingatan',
                  body: 'Setiap gambar muncul selama 3 detik.',
                ),
                const SizedBox(height: 12),
                _InfoStrip(
                  icon: Icons.timer,
                  title: 'Fase tebakan',
                  body: 'Setiap pertanyaan memiliki timer 30 detik.',
                ),
                const SizedBox(height: 12),
                _InfoStrip(
                  icon: Icons.emoji_events,
                  title: 'High score',
                  body: 'Skor terbaik tiap pemain disimpan otomatis.',
                ),
                const SizedBox(height: 26),
                // Tombol mulai game: membuka GameScreen dengan username aktif.
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => GameScreen(username: username),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play Game'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Bagian Drawer Menu
// ============================================================
// Drawer: menampilkan username, high score, dan logout.
class _MainDrawer extends StatelessWidget {
  const _MainDrawer({required this.username, required this.onLogout});

  final String username;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Text(
                    username.isEmpty ? '?' : username[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard),
            title: const Text('High Score'),
            onTap: () {
              // Tutup drawer dulu, lalu masuk ke halaman High Score.
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const HighScoreScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () async {
              // Logout menghapus session username dari SharedPreferences.
              Navigator.pop(context);
              await onLogout();
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Bagian Komponen Info Main Menu
// ============================================================
// Komponen informasi kecil di main menu.
class _InfoStrip extends StatelessWidget {
  const _InfoStrip({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E8EA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.tertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Bagian Game Screen dan Game Logic
// ============================================================
// GameScreen: mengatur seluruh alur permainan, timer, soal, dan skor.
class GameScreen extends StatefulWidget {
  const GameScreen({required this.username, super.key});

  final String username;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

// Phase game: preparing, menampilkan gambar, lalu menjawab soal.
enum GamePhase { preparing, memorizing, answering }

class _GameScreenState extends State<GameScreen> {
  final Random _random = Random();

  // Target dan opsi jawaban untuk ronde game saat ini.
  late final List<GameItem> _targets;
  List<GameItem> _options = const [];

  // State utama permainan.
  GamePhase _phase = GamePhase.preparing;
  int _sequenceIndex = 0;
  int _questionIndex = 0;
  int _sequenceSecondsLeft = _memorizeSeconds;
  int _answerSecondsLeft = _answerSeconds;
  int _score = 0;
  int _correctAnswers = 0;

  // Lock jawaban agar user tidak bisa klik berkali-kali.
  bool _answerLocked = false;
  String? _selectedOptionId;

  // Timer untuk fase hafalan, fase jawaban, dan jeda antar soal.
  Timer? _sequenceTimer;
  Timer? _questionTimer;
  Timer? _transitionTimer;

  @override
  void initState() {
    super.initState();
    _targets = _buildTargets();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Mulai fase hafalan setelah frame pertama selesai dibuat.
      if (mounted) {
        _showMemoryImage(0);
      }
    });
  }

  @override
  void dispose() {
    // Semua timer dibatalkan agar tidak memanggil setState setelah screen hilang.
    _sequenceTimer?.cancel();
    _questionTimer?.cancel();
    _transitionTimer?.cancel();
    super.dispose();
  }

  // Random target: pilih kategori acak lalu ambil satu gambar dari tiap kategori.
  List<GameItem> _buildTargets() {
    final categories = kGameItems.map((item) => item.category).toSet().toList()
      ..shuffle(_random);

    return categories.take(_roundsPerGame).map((category) {
      final candidates =
          kGameItems.where((item) => item.category == category).toList()
            ..shuffle(_random);
      return candidates.first;
    }).toList();
  }

  // Opsi jawaban: semua gambar dengan kategori yang sama agar pilihan mirip.
  List<GameItem> _buildOptions(GameItem target) {
    final options =
        kGameItems.where((item) => item.category == target.category).toList()
          ..shuffle(_random);
    return options;
  }

  // Fase hafalan: tampilkan satu gambar selama beberapa detik.
  void _showMemoryImage(int index) {
    _sequenceTimer?.cancel();
    _questionTimer?.cancel();

    if (index >= _targets.length) {
      _startQuestion(0);
      return;
    }

    setState(() {
      _phase = GamePhase.memorizing;
      _sequenceIndex = index;
      _sequenceSecondsLeft = _memorizeSeconds;
    });

    // Timer countdown untuk berpindah otomatis ke gambar berikutnya.
    _sequenceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_sequenceSecondsLeft <= 1) {
        timer.cancel();
        _showMemoryImage(index + 1);
      } else {
        setState(() {
          _sequenceSecondsLeft -= 1;
        });
      }
    });
  }

  // Fase soal: tampilkan opsi jawaban dan mulai timer 30 detik.
  void _startQuestion(int index) {
    _sequenceTimer?.cancel();
    _questionTimer?.cancel();
    _transitionTimer?.cancel();

    if (index >= _targets.length) {
      _finishGame();
      return;
    }

    setState(() {
      _phase = GamePhase.answering;
      _questionIndex = index;
      _options = _buildOptions(_targets[index]);
      _answerSecondsLeft = _answerSeconds;
      _answerLocked = false;
      _selectedOptionId = null;
    });

    // Timer countdown jawaban; jika habis, soal dianggap timeout.
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_answerSecondsLeft <= 1) {
        timer.cancel();
        _timeoutQuestion();
      } else {
        setState(() {
          _answerSecondsLeft -= 1;
        });
      }
    });
  }

  // Proses klik jawaban: cek benar/salah, update skor, lalu lanjut soal.
  void _selectOption(GameItem option) {
    if (_answerLocked) {
      return;
    }

    _questionTimer?.cancel();
    final target = _targets[_questionIndex];
    final isCorrect = option.id == target.id;

    setState(() {
      _answerLocked = true;
      _selectedOptionId = option.id;
      if (isCorrect) {
        // Scoring: jawaban benar mendapat poin sebesar sisa detik.
        _score += _answerSecondsLeft;
        _correctAnswers += 1;
      }
    });

    _queueNextQuestion();
  }

  // Timeout: user tidak memilih sampai timer habis.
  void _timeoutQuestion() {
    if (_answerLocked) {
      return;
    }

    setState(() {
      _answerSecondsLeft = 0;
      _answerLocked = true;
      _selectedOptionId = null;
    });

    _queueNextQuestion();
  }

  // Jeda singkat agar user sempat melihat indikator benar/salah.
  void _queueNextQuestion() {
    _transitionTimer?.cancel();
    _transitionTimer = Timer(const Duration(milliseconds: 750), () {
      if (mounted) {
        _startQuestion(_questionIndex + 1);
      }
    });
  }

  // Akhiri game dan pindah ke result screen.
  void _finishGame() {
    _sequenceTimer?.cancel();
    _questionTimer?.cancel();
    _transitionTimer?.cancel();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          username: widget.username,
          score: _score,
          correctAnswers: _correctAnswers,
          totalQuestions: _targets.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permainan')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              // AnimatedSwitcher memberi transisi saat phase game berubah.
              child: switch (_phase) {
                GamePhase.preparing => const Center(
                  key: ValueKey('preparing'),
                  child: CircularProgressIndicator(),
                ),
                GamePhase.memorizing => _buildMemoryView(context),
                GamePhase.answering => _buildQuestionView(context),
              },
            ),
          ),
        ),
      ),
    );
  }

  // Tampilan fase hafalan.
  Widget _buildMemoryView(BuildContext context) {
    final target = _targets[_sequenceIndex];

    return ListView(
      key: const ValueKey('memory'),
      padding: const EdgeInsets.all(24),
      children: [
        _GameStatusBar(
          leadingLabel: 'Ingat gambar',
          progressLabel: '${_sequenceIndex + 1}/${_targets.length}',
          score: _score,
        ),
        const SizedBox(height: 24),
        Text(
          'Perhatikan gambar ini',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'Gambar berikutnya akan muncul otomatis.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 26),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: _MemoryImageCard(
            key: ValueKey(target.id),
            item: target,
            secondsLeft: _sequenceSecondsLeft,
          ),
        ),
      ],
    );
  }

  // Tampilan fase pertanyaan dan pilihan jawaban.
  Widget _buildQuestionView(BuildContext context) {
    final target = _targets[_questionIndex];

    // LayoutBuilder dipakai agar jumlah kolom opsi responsif.
    return LayoutBuilder(
      key: const ValueKey('question'),
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 700 ? 4 : 2;

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _GameStatusBar(
              leadingLabel: 'Pilih jawaban',
              progressLabel: '${_questionIndex + 1}/${_targets.length}',
              score: _score,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: _answerSecondsLeft / _answerSeconds,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 14),
                _TimerPill(secondsLeft: _answerSecondsLeft),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Gambar mana yang tadi muncul?',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            // Grid opsi jawaban: 4 kolom di layar lebar, 2 kolom di layar kecil.
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _options.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final option = _options[index];
                return _OptionTile(
                  item: option,
                  isLocked: _answerLocked,
                  isSelected: option.id == _selectedOptionId,
                  isCorrectAnswer: option.id == target.id,
                  onTap: () => _selectOption(option),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// Bagian Komponen UI Reusable Untuk Game
// ============================================================
// Status bar game: phase, progress, dan skor.
class _GameStatusBar extends StatelessWidget {
  const _GameStatusBar({
    required this.leadingLabel,
    required this.progressLabel,
    required this.score,
  });

  final String leadingLabel;
  final String progressLabel;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _StatusPill(icon: Icons.image, label: leadingLabel),
        _StatusPill(icon: Icons.flag, label: progressLabel),
        _StatusPill(icon: Icons.stars, label: '$score poin'),
      ],
    );
  }
}

// Komponen label status berbentuk pill.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E7EA)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 7),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

// Timer UI: berubah warna saat waktu hampir habis.
class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.secondsLeft});

  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    final isUrgent = secondsLeft <= 5;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isUrgent ? const Color(0xFFFFE1D7) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUrgent ? const Color(0xFFE76F51) : const Color(0xFFE0E7EA),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 18,
            color: isUrgent
                ? const Color(0xFFC2410C)
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            '$secondsLeft dtk',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

// Card gambar pada fase hafalan.
class _MemoryImageCard extends StatelessWidget {
  const _MemoryImageCard({
    required this.item,
    required this.secondsLeft,
    super.key,
  });

  final GameItem item;
  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E7EA)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              item.assetPath,
              semanticLabel: '${item.colorName} ${item.objectName}',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: Text(
                  '$secondsLeft',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tile pilihan jawaban: menampilkan border hijau/merah setelah dikunci.
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.item,
    required this.isLocked,
    required this.isSelected,
    required this.isCorrectAnswer,
    required this.onTap,
  });

  final GameItem item;
  final bool isLocked;
  final bool isSelected;
  final bool isCorrectAnswer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final IconData? badgeIcon;
    final Color? badgeColor;

    // Warna dan icon feedback:
    // hijau untuk jawaban benar, merah untuk pilihan salah.
    if (isLocked && isCorrectAnswer) {
      borderColor = const Color(0xFF16A34A);
      badgeIcon = Icons.check_circle;
      badgeColor = const Color(0xFF16A34A);
    } else if (isLocked && isSelected) {
      borderColor = const Color(0xFFDC2626);
      badgeIcon = Icons.cancel;
      badgeColor = const Color(0xFFDC2626);
    } else {
      borderColor = const Color(0xFFE0E7EA);
      badgeIcon = null;
      badgeColor = null;
    }

    return Semantics(
      button: true,
      label: 'Pilihan ${item.objectName}',
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: isLocked ? 3 : 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Image.asset(
                  item.assetPath,
                  semanticLabel: '${item.colorName} ${item.objectName}',
                  fit: BoxFit.contain,
                ),
              ),
              if (badgeIcon != null && badgeColor != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(badgeIcon, color: badgeColor, size: 30),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Bagian Result Screen
// ============================================================
// Result screen: menampilkan skor, gelar, dan tombol navigasi setelah game.
class ResultScreen extends StatefulWidget {
  const ResultScreen({
    required this.username,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    super.key,
  });

  final String username;
  final int score;
  final int correctAnswers;
  final int totalQuestions;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final Future<bool> _saveFuture;

  @override
  void initState() {
    super.initState();
    // SharedPreferences: simpan score jika menjadi personal best.
    _saveFuture = HighScoreRepository.saveIfPersonalBest(
      username: widget.username,
      score: widget.score,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = titleForCorrectAnswers(widget.correctAnswers);

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Image.asset('assets/ranks/rank_1.png', width: 128, height: 128),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 850),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(begin: 0, end: widget.score.toDouble()),
                  // Animasi angka score dari 0 ke score akhir.
                  builder: (context, value, child) {
                    return Text(
                      '${value.round()} poin',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.correctAnswers} dari ${widget.totalQuestions} tebakan berhasil dijawab',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                // FutureBuilder menunggu proses simpan high score selesai.
                FutureBuilder<bool>(
                  future: _saveFuture,
                  builder: (context, snapshot) {
                    final isSaved = snapshot.data ?? false;
                    final message =
                        snapshot.connectionState == ConnectionState.waiting
                        ? 'Menyimpan skor...'
                        : isSaved
                        ? 'High score baru tersimpan'
                        : 'High score pribadi belum berubah';

                    return _ResultNotice(
                      icon: isSaved ? Icons.workspace_premium : Icons.save,
                      message: message,
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Play Again mengganti ResultScreen dengan GameScreen baru.
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => GameScreen(username: widget.username),
                      ),
                    );
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Play Again'),
                ),
                const SizedBox(height: 12),
                // High Scores membuka leaderboard lokal.
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const HighScoreScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.leaderboard),
                  label: const Text('High Scores'),
                ),
                const SizedBox(height: 12),
                // Main Menu kembali ke route pertama.
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Main Menu'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Bagian Result Notice
// ============================================================
// Notice hasil penyimpanan score pada result screen.
class _ResultNotice extends StatelessWidget {
  const _ResultNotice({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E7EA)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.tertiary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Bagian High Score Screen
// ============================================================
// High score screen: membaca dan menampilkan ranking pemain.
class HighScoreScreen extends StatefulWidget {
  const HighScoreScreen({super.key});

  @override
  State<HighScoreScreen> createState() => _HighScoreScreenState();
}

class _HighScoreScreenState extends State<HighScoreScreen> {
  late Future<List<ScoreEntry>> _scoresFuture;

  @override
  void initState() {
    super.initState();
    _scoresFuture = HighScoreRepository.loadTopScores();
  }

  // Refresh data high score dari SharedPreferences.
  void _refresh() {
    setState(() {
      _scoresFuture = HighScoreRepository.loadTopScores();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('High Score'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: FutureBuilder<List<ScoreEntry>>(
              future: _scoresFuture,
              builder: (context, snapshot) {
                // Loading state saat data high score sedang dibaca.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final scores = snapshot.data ?? const <ScoreEntry>[];
                // Empty state jika belum ada pemain yang menyimpan score.
                if (scores.isEmpty) {
                  return _EmptyScores(onRefresh: _refresh);
                }

                // List ranking high score.
                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemBuilder: (context, index) {
                    return _ScoreCard(entry: scores[index], rank: index + 1);
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemCount: scores.length,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Bagian Empty State High Score
// ============================================================
// Empty state jika belum ada data high score.
class _EmptyScores extends StatelessWidget {
  const _EmptyScores({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada skor',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mainkan satu ronde untuk mengisi papan high score.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Bagian Card High Score
// ============================================================
// Card untuk satu entry high score.
class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.entry, required this.rank});

  final ScoreEntry entry;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Image.asset('assets/ranks/rank_$rank.png', width: 72, height: 72),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rank $rank',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${entry.score}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Bagian Model High Score
// ============================================================
// Model data high score.
class ScoreEntry {
  const ScoreEntry({required this.username, required this.score});

  final String username;
  final int score;

  // Mengubah object ScoreEntry menjadi Map agar bisa di-JSON-kan.
  Map<String, Object> toJson() {
    return <String, Object>{'username': username, 'score': score};
  }

  // Parsing data JSON dari SharedPreferences menjadi ScoreEntry.
  static ScoreEntry? fromStorage(String raw) {
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final username = data['username'] as String?;
      final scoreValue = data['score'];
      final score = scoreValue is int
          ? scoreValue
          : scoreValue is num
          ? scoreValue.toInt()
          : int.tryParse('$scoreValue');

      if (username == null || username.isEmpty || score == null) {
        return null;
      }

      return ScoreEntry(username: username, score: score);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}

// ============================================================
// Bagian Repository High Score / SharedPreferences Score
// ============================================================
// Repository high score: semua akses SharedPreferences untuk skor ada di sini.
class HighScoreRepository {
  const HighScoreRepository._();

  // SharedPreferences: ambil top 3 score untuk ditampilkan.
  static Future<List<ScoreEntry>> loadTopScores() async {
    final scores = await _loadScores();
    return scores.take(3).toList();
  }

  // SharedPreferences: simpan score hanya jika lebih tinggi dari score user itu.
  static Future<bool> saveIfPersonalBest({
    required String username,
    required int score,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final scores = await _loadScores();
    final previousBest = scores
        .where((entry) => entry.username == username)
        .map((entry) => entry.score)
        .fold<int>(-1, max);

    // Jika score baru tidak lebih tinggi, data tidak perlu ditulis ulang.
    if (score <= previousBest) {
      return false;
    }

    // Hapus score lama user yang sama, lalu masukkan personal best terbaru.
    final nextScores =
        scores.where((entry) => entry.username != username).toList()
          ..add(ScoreEntry(username: username, score: score))
          ..sort(_sortScores);

    // Storage dibatasi 10 score terbaik agar data lokal tetap ringkas.
    final encoded = nextScores
        .take(10)
        .map((entry) => jsonEncode(entry.toJson()))
        .toList();
    await prefs.setStringList(_highScoresKey, encoded);
    return true;
  }

  // SharedPreferences: baca semua score, parsing JSON, lalu sort descending.
  static Future<List<ScoreEntry>> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final storedValues =
        prefs.getStringList(_highScoresKey) ?? const <String>[];
    final scores =
        storedValues
            .map(ScoreEntry.fromStorage)
            .whereType<ScoreEntry>()
            .toList()
          ..sort(_sortScores);
    return scores;
  }

  // Sorting: score terbesar dulu, lalu username alfabetis jika score sama.
  static int _sortScores(ScoreEntry a, ScoreEntry b) {
    final scoreComparison = b.score.compareTo(a.score);
    if (scoreComparison != 0) {
      return scoreComparison;
    }
    return a.username.toLowerCase().compareTo(b.username.toLowerCase());
  }
}

// ============================================================
// Bagian Gelar Result
// ============================================================
// Gelar Italia berdasarkan jumlah jawaban benar.
String titleForCorrectAnswers(int correctAnswers) {
  return switch (correctAnswers) {
    5 => "Maestro dell'Indovinello",
    4 => "Esperto dell'Indovinello",
    3 => 'Abile Indovinatore',
    2 => "Principiante dell'Indovinello",
    1 => "Neofita dell'Indovinello",
    _ => 'Sfortunato Indovinatore',
  };
}

// ============================================================
// Bagian Model Data Gambar Game
// ============================================================
// Model data gambar game.
class GameItem {
  const GameItem({
    required this.id,
    required this.category,
    required this.objectName,
    required this.colorName,
    required this.assetPath,
  });

  final String id;
  final String category;
  final String objectName;
  final String colorName;
  final String assetPath;
}

// ============================================================
// Bagian Master Data Asset Game
// ============================================================
// Master data semua asset gambar yang dipakai sebagai target dan opsi jawaban.
const List<GameItem> kGameItems = [
  GameItem(
    id: 'pencil_red',
    category: 'pencil',
    objectName: 'pensil',
    colorName: 'merah',
    assetPath: 'assets/memorimage/pencil_red.png',
  ),
  GameItem(
    id: 'pencil_blue',
    category: 'pencil',
    objectName: 'pensil',
    colorName: 'biru',
    assetPath: 'assets/memorimage/pencil_blue.png',
  ),
  GameItem(
    id: 'pencil_green',
    category: 'pencil',
    objectName: 'pensil',
    colorName: 'hijau',
    assetPath: 'assets/memorimage/pencil_green.png',
  ),
  GameItem(
    id: 'pencil_yellow',
    category: 'pencil',
    objectName: 'pensil',
    colorName: 'kuning',
    assetPath: 'assets/memorimage/pencil_yellow.png',
  ),
  GameItem(
    id: 'bottle_red',
    category: 'bottle',
    objectName: 'botol',
    colorName: 'merah',
    assetPath: 'assets/memorimage/bottle_red.png',
  ),
  GameItem(
    id: 'bottle_blue',
    category: 'bottle',
    objectName: 'botol',
    colorName: 'biru',
    assetPath: 'assets/memorimage/bottle_blue.png',
  ),
  GameItem(
    id: 'bottle_green',
    category: 'bottle',
    objectName: 'botol',
    colorName: 'hijau',
    assetPath: 'assets/memorimage/bottle_green.png',
  ),
  GameItem(
    id: 'bottle_yellow',
    category: 'bottle',
    objectName: 'botol',
    colorName: 'kuning',
    assetPath: 'assets/memorimage/bottle_yellow.png',
  ),
  GameItem(
    id: 'mug_red',
    category: 'mug',
    objectName: 'mug',
    colorName: 'merah',
    assetPath: 'assets/memorimage/mug_red.png',
  ),
  GameItem(
    id: 'mug_blue',
    category: 'mug',
    objectName: 'mug',
    colorName: 'biru',
    assetPath: 'assets/memorimage/mug_blue.png',
  ),
  GameItem(
    id: 'mug_green',
    category: 'mug',
    objectName: 'mug',
    colorName: 'hijau',
    assetPath: 'assets/memorimage/mug_green.png',
  ),
  GameItem(
    id: 'mug_yellow',
    category: 'mug',
    objectName: 'mug',
    colorName: 'kuning',
    assetPath: 'assets/memorimage/mug_yellow.png',
  ),
  GameItem(
    id: 'book_red',
    category: 'book',
    objectName: 'buku',
    colorName: 'merah',
    assetPath: 'assets/memorimage/book_red.png',
  ),
  GameItem(
    id: 'book_blue',
    category: 'book',
    objectName: 'buku',
    colorName: 'biru',
    assetPath: 'assets/memorimage/book_blue.png',
  ),
  GameItem(
    id: 'book_green',
    category: 'book',
    objectName: 'buku',
    colorName: 'hijau',
    assetPath: 'assets/memorimage/book_green.png',
  ),
  GameItem(
    id: 'book_yellow',
    category: 'book',
    objectName: 'buku',
    colorName: 'kuning',
    assetPath: 'assets/memorimage/book_yellow.png',
  ),
  GameItem(
    id: 'watch_red',
    category: 'watch',
    objectName: 'jam',
    colorName: 'merah',
    assetPath: 'assets/memorimage/watch_red.png',
  ),
  GameItem(
    id: 'watch_blue',
    category: 'watch',
    objectName: 'jam',
    colorName: 'biru',
    assetPath: 'assets/memorimage/watch_blue.png',
  ),
  GameItem(
    id: 'watch_green',
    category: 'watch',
    objectName: 'jam',
    colorName: 'hijau',
    assetPath: 'assets/memorimage/watch_green.png',
  ),
  GameItem(
    id: 'watch_yellow',
    category: 'watch',
    objectName: 'jam',
    colorName: 'kuning',
    assetPath: 'assets/memorimage/watch_yellow.png',
  ),
  GameItem(
    id: 'camera_red',
    category: 'camera',
    objectName: 'kamera',
    colorName: 'merah',
    assetPath: 'assets/memorimage/camera_red.png',
  ),
  GameItem(
    id: 'camera_blue',
    category: 'camera',
    objectName: 'kamera',
    colorName: 'biru',
    assetPath: 'assets/memorimage/camera_blue.png',
  ),
  GameItem(
    id: 'camera_green',
    category: 'camera',
    objectName: 'kamera',
    colorName: 'hijau',
    assetPath: 'assets/memorimage/camera_green.png',
  ),
  GameItem(
    id: 'camera_yellow',
    category: 'camera',
    objectName: 'kamera',
    colorName: 'kuning',
    assetPath: 'assets/memorimage/camera_yellow.png',
  ),
];
