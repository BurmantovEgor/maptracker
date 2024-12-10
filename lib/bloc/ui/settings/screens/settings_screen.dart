import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Индекс текущей страницы (карта)
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
            Navigator.pushNamed(context, '/map');
          },
        ),
      ),
      body: Center(
        child: Text(
          'Настройки',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
