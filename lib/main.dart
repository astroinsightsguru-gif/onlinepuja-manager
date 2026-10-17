import 'package:flutter/material.dart';
import 'theme/manager_theme.dart';
import 'ui/screens/manager_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OnlinePujaManagerApp());
}

class OnlinePujaManagerApp extends StatelessWidget {
  const OnlinePujaManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnlinePuja Manager',
      debugShowCheckedModeBanner: false,
      theme: ManagerTheme.darkTheme,
      home: const ManagerShell(),
    );
  }
}
