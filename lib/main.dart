import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paigun/page/authentication/login.dart';
import 'package:paigun/page/components/loading_screen.dart';
import 'package:paigun/page/components/splash_screen.dart';
import 'package:paigun/page/driver/component/createroute.dart';
import 'package:paigun/page/passenger/components/journeyboard.dart';
import 'package:paigun/page/driver/home.dart';
import 'package:paigun/page/passenger/home.dart';
import 'package:paigun/provider/userinfo.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'provider/driver.dart';
import 'provider/passenger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_KEY'] ?? '',
  );
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => UserInfo()),
    ChangeNotifierProvider(create: (_) => PassDB()),
    ChangeNotifierProvider(create: (_) => DriveDB()),
  ], child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Paigun',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(42, 66, 188, 1),
          brightness: Brightness.light,
          primary: const Color.fromRGBO(42, 66, 188, 1),
          secondary: const Color.fromARGB(255, 119, 119, 121),
          tertiary: const Color.fromRGBO(42, 66, 188, 1),
          error: const Color.fromARGB(255, 212, 82, 82),
        ),
        fontFamily: GoogleFonts.nunito().fontFamily,
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const Login(),
        '/home': (context) => const PassengerHome(),
        '/journeyboard': (context) => const Journeyboard(),
        '/loading': (context) => const Loading(),
        '/driver': (context) => const DriverHome(),
        '/driver/create': (context) => const CreateRoute(),
      },
    );
  }
}
