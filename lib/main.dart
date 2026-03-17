import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'pages/homepage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Use ?? to provide an empty string if the key is missing,
  // preventing the "Null check" crash.
  String apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";

  if (apiKey.isEmpty) {
    print("❌ ERROR: Key is missing from .env file!");
  }

  Gemini.init(apiKey: apiKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Homepage());
  }
}
