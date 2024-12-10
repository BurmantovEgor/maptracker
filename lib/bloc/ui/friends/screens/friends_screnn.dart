import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPeopleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Индекс текущей страницы (карта)
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/settings');
          } else if (index == 0) {
            Navigator.pushNamed(context, '/map');
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
        title: Text('Поиск людей'),
        leading: BackButton(
          onPressed: () {
            Navigator.pushNamed(context, '/map');
          },
        ),
      ),
      body: Center(
        child: Text(
          'Поиск людей',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}