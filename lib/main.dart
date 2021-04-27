import 'package:flutter/material.dart';
import 'package:resocoder_clean_arch/features/number_trivia/presentation/pages/number_trivia_page.dart';
import 'injection_container.dart' as getIt;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  getIt.init().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Trivia',
      theme: ThemeData(
        primaryColor: Colors.green.shade800,
        accentColor: Colors.green.shade600,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.green.shade800,
          ),
        ),
      ),
      home: NumberTriviaPage(),
    );
  }
}
