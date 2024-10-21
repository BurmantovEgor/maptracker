import 'package:flutter/material.dart';
import 'package:map_tracker/presentation/screens/main_screen.dart';
import 'package:map_tracker/presentation/screens/map_screen.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:map_tracker/domain/user.dart';

class AuthorizationScreen extends StatefulWidget {
  const AuthorizationScreen({super.key});

  @override
  State<AuthorizationScreen> createState() => _AuthorizationScreenState();
}

class _AuthorizationScreenState extends State<AuthorizationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Тестовое приложение",
            style: TextStyle(),
          ),
        ),
        body: Center(
            child: SingleChildScrollView(
                child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2, color: Colors.black),
                      borderRadius: BorderRadius.circular(20)),
                  hintText: 'Номер телефона',
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2, color: Colors.black),
                        borderRadius: BorderRadius.circular(20)),
                    hintText: 'Пароль'),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return MapScreen();
                    }));
                  },
                  child: Text("LogIn"))
            ],
          ),
        ))));
  }
}
