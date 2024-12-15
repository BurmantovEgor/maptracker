import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../bloc/point/point_block.dart';
import '../../../bloc/point/point_event.dart';
import '../../../bloc/user/user_block.dart';
import '../../../bloc/user/user_event.dart';
import '../../../data/models/user.dart';

class SettingsScreen extends StatelessWidget {
  final User currentUser;

  const SettingsScreen({required this.currentUser, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/map');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/search');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Карта',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Поиск людей',
          ),
        ],
      ),
      appBar: AppBar(
        title: Text('Настройки'),
      ),
      body: Center(
          child: Column(children: [
        ElevatedButton(
          onPressed: () async {
            final SharedPreferences prefs =
            await SharedPreferences.getInstance();
            prefs.clear();
            final pointBloc = context.read<PointBloc>();
            pointBloc.add(LoadPointsEvent(''));
            Navigator.pop(
                context,
                User(
                    id: 0,
                    email: '',
                    username: '',
                    isAuthorized: false,
                    jwt: ''));
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.grey.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
            elevation: 5,
          ),
          child: const Text(
            'Выйти',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            UserBloc userBloc = context.read<UserBloc>();
            userBloc.add(LoginUserEvent(email: 'egor@exa1mple.com', password: 'string'));
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.grey.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.symmetric(vertical: 15),
            elevation: 5,
          ),
          child: const Text(
            'Войти',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ])),
    );
  }
}
