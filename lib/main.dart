import 'package:apex_test_app/Providers/lang_provider.dart';
import 'package:apex_test_app/Screens/login_screen.dart';
import 'package:apex_test_app/Screens/map_page.dart';
import 'package:apex_test_app/Screens/register_screen.dart';
import 'package:apex_test_app/Shared%20Preferences/shared_preferences_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesController().initSharedPreferences();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return RestartWidget(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<LocationProvider>(
            create: (context) => LocationProvider(),
          ),
        ],
        child: MyMaterialApp(),
      ),
    );
  }
}

class MyMaterialApp extends StatelessWidget {


  const MyMaterialApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Cairo'),
      debugShowCheckedModeBanner: false,
      routes: {
        // '/launch_screen': (context) => const LaunchScreen(),
        // '/intro_screen': (context) => const IntroScreen(),
        '/login_screen': (context) => const LoginScreen(),
        '/register_screen': (context) => const RegisterScreen(),
        '/map_screen': (context) => const MapPage(),
        // '/main_screen': (context) => const MainScreen(),
        // '/notifications_screen': (context) => const NotificationsScreen(),
      },
      initialRoute: SharedPreferencesController().checkLoggedIn == true
          ? '/map_screen'
          : '/login_screen',
      // localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      locale: const Locale('en'),
    );


  }

}



// FOR RESTARTING APP
// CALL IT FROM ANYWHERE USING => RestartWidget.restartApp(context)

class RestartWidget extends StatefulWidget {
  const RestartWidget({Key? key, required this.child}) : super(key: key);

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()!.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
