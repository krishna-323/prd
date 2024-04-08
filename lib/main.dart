import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home/home_screen.dart';
import 'login_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userName = prefs.getString('userName');
  String? password = prefs.getString('password');
  String? plantValue = prefs.getString('plant');
  runApp(MyApp(initialUserName: userName, initialPassword: password, initialPlantValue: plantValue));
}

class MyApp extends StatelessWidget {
  final String? initialUserName;
  final String? initialPassword;
  final String? initialPlantValue;
  const MyApp({
    this.initialUserName,
    this.initialPassword,
    this.initialPlantValue,
    super.key
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'jmi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          fontFamily: "TitilliumWeb"
      ),
      home: initialUserName != null && initialPassword != null && initialPlantValue != null
          ? HomeScreen(drawerWidth: 190, selectedDestination: 0, plantValue: initialPlantValue!)
          : const LoginScreen(),
    );
  }
}

