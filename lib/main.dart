import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'component/consent_dialog.dart';
import 'screens/splash_screen.dart';
import 'screens/insert_screen.dart';
import 'screens/home_screen.dart';
import 'screens/records_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
  runApp(const CognitiveJournalApp());
}

class CognitiveJournalApp extends StatelessWidget {
  const CognitiveJournalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("APP STARTED WITH MAIN.DART");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Splash runs first
    );
  }
}

// ----------------------------------------------------------------------------
// CONSENT WRAPPER
// ----------------------------------------------------------------------------

class ConsentWrapper extends StatefulWidget {
  const ConsentWrapper({Key? key}) : super(key: key);

  @override
  State<ConsentWrapper> createState() => _ConsentWrapperState();
}

class _ConsentWrapperState extends State<ConsentWrapper> {
  bool _loading = true;
  bool _consent = false;

  @override
  void initState() {
    super.initState();
    print("[ConsentWrapper] initState triggered");
    _checkConsent();
  }

  Future<void> _checkConsent() async {
    print("[ConsentWrapper] Checking consent in SQLite...");
    final v = await DatabaseHelper().getConsent();
    print("[ConsentWrapper] SQLite returned consent: $v");

    setState(() {
      _consent = v;
      _loading = false;
    });

    if (!v) {
      print("[ConsentWrapper] Consent is FALSE → preparing to show dialog...");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showConsentDialog();
      });
    } else {
      print("[ConsentWrapper] Consent is TRUE → navigating to main app");
    }
  }

  void _showConsentDialog() {
    print("[ConsentWrapper] showConsentDialog() called!!!");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        print("[ConsentWrapper] ConsentDialog BUILDER executed");
        return ConsentDialog(
          onConfirm: () async {
            print("[ConsentDialog] User confirmed consent!");
            await DatabaseHelper().setConsent(true);
            print("[ConsentDialog] Consent stored to SQLite = TRUE");
            Navigator.pop(context);
            setState(() => _consent = true);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
        "[ConsentWrapper] build() called | loading: $_loading | consent: $_consent");

    if (_loading) {
      print("[ConsentWrapper] Showing LOADING screen");
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF7b2cbf)),
        ),
      );
    }

    if (!_consent) {
      print(
          "[ConsentWrapper] Consent FALSE → showing EMPTY SCREEN (dialog will appear on top)");
      return const Scaffold(
        backgroundColor: Color(0xFFfaf7ff),
      );
    }

    print("[ConsentWrapper] Consent TRUE → showing MainNavigation");
    return const MainNavigation();
  }
}

// ----------------------------------------------------------------------------
// MAIN NAVIGATION
// ----------------------------------------------------------------------------

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;
  final screens = const [InsertScreen(), HomeScreen(), RecordsScreen()];

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
