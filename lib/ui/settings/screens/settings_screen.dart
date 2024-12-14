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
        leading: BackButton(
          onPressed: () {
            UserBloc userBloc = context.read<UserBloc>();
            userBloc.add(LoginUserEvent(
                email: 'egor@exa1mple.com', password: 'string'));

            Navigator.pop(
                context,
                User(
                    id: 0,
                    email: 'use123@exa1mple123.com',
                    username: '',
                    isAuthorized: true,
                    jwt:
                        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6ImM0NDk4NTEzLTNjZmMtNGYzNS1iYTFlLWQzMzlhY2ZmMWVhZCIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL25hbWUiOiJzdHJpbmcxMTEyMyIsImV4cCI6MTczMzkyMjE5NCwiaXNzIjoibWVtZW1lbWUiLCJhdWQiOiJjbGllbnRzIn0.FYw0FiEuqXkMNKDc8aje-F5oHyKTHVmSNGtb0NCoR10'));
          },
        ),
      ),
      body: Center(
        child: ElevatedButton(
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
            padding: EdgeInsets.symmetric(vertical: 15),
            elevation: 5,
          ),
          child: const Text(
            'Выйти',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
