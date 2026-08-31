import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/landingpage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xlwcbgbkhikmjkxmxlvr.supabase.co',
    publishableKey: 'sb_publishable_4JflIDCA0fP__2YBscobNA_fe40UHQc',
  );

  runApp(const CalaSenseApp());
}

class CalaSenseApp extends StatelessWidget {
  const CalaSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CalaSense',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,

        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.light().textTheme,
        ),

        primaryTextTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.light().primaryTextTheme,
        ),
      ),
      home: const LandingPage(),
    );
  }
}