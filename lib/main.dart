
import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'component/consent_dialog.dart';
import 'screens/splash_screen.dart';
import 'screens/insert_screen.dart';
import 'screens/home_screen.dart';
import 'screens/records_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
  runApp(const CognitiveJournalApp());
}

class CognitiveJournalApp extends StatefulWidget {
  const CognitiveJournalApp({Key? key}) : super(key: key);

  @override
  State<CognitiveJournalApp> createState() => _CognitiveJournalAppState();
}

class _CognitiveJournalAppState extends State<CognitiveJournalApp> {
  final ThemeController _themeController = ThemeController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              _themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // 🔑 SplashScreen handles navigation itself
          home: SplashScreen(
            themeController: _themeController,
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// CONSENT WRAPPER
// -----------------------------------------------------------------------------

class ConsentWrapper extends StatefulWidget {
  final ThemeController themeController;

  const ConsentWrapper({
    Key? key,
    required this.themeController,
  }) : super(key: key);

  @override
  State<ConsentWrapper> createState() => _ConsentWrapperState();
}

class _ConsentWrapperState extends State<ConsentWrapper> {
  bool _loading = true;
  bool _consent = false;

  @override
  void initState() {
    super.initState();
    _checkConsent();
  }

  Future<void> _checkConsent() async {
    final v = await DatabaseHelper().getConsent();

    setState(() {
      _consent = v;
      _loading = false;
    });

    if (!v) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showConsentDialog();
      });
    }
  }

  void _showConsentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConsentDialog(
        onConfirm: () async {
          await DatabaseHelper().setConsent(true);
          Navigator.pop(context);
          setState(() => _consent = true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF7b2cbf),
          ),
        ),
      );
    }

    if (!_consent) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      );
    }

    return MainNavigation(
      themeController: widget.themeController,
    );
  }
}

// -----------------------------------------------------------------------------
// MAIN NAVIGATION
// -----------------------------------------------------------------------------

class MainNavigation extends StatefulWidget {
  final ThemeController themeController;

  const MainNavigation({
    Key? key,
    required this.themeController,
  }) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      InsertScreen(themeController: widget.themeController),
      HomeScreen(themeController: widget.themeController),
      RecordsScreen(themeController: widget.themeController),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: "Add Entry",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: "Today",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Records",
          ),
        ],
      ),
    );
  }
}
