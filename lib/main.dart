// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/data/user/user_block.dart';
import 'bloc/point/point_block.dart';
import 'bloc/ui/friends/screens/friends_screnn.dart';
import 'bloc/ui/mainMap/screens/map_screen.dart';
import 'bloc/ui/settings/screens/settings_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PointBloc>(
          create: (context) => PointBloc(),
        ),
        BlocProvider<LocationBloc>(
          create: (context) => LocationBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Travel Tracker',
        initialRoute: '/map',
        routes: {
          '/map': (context) => MapScreen(),
          '/settings': (context) => SettingsScreen(),
          '/search': (context) => SearchPeopleScreen(),
        },
      ),
    );
  }
}
