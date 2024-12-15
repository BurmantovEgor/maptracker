// lib/main.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_tracker/bloc/user/userSearch_block.dart';
import 'package:map_tracker/bloc/user/user_block.dart';
import 'package:map_tracker/data/models/user.dart';
import 'package:map_tracker/service/palce_service.dart';
import 'package:map_tracker/service/user_service.dart';
import 'package:map_tracker/ui/friends/screens/friends_screnn.dart';
import 'package:map_tracker/ui/mainMap/screens/map_screen.dart';
import 'package:map_tracker/ui/settings/screens/settings_screen.dart';

import 'bloc/location/location_block.dart';
import 'bloc/point/point_block.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PointBloc>(
          create: (context) => PointBloc(new PlaceService()),
        ),
        BlocProvider<LocationBloc>(
          create: (context) => LocationBloc(),
        ),
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(new UserService()),
        ),
        BlocProvider<UserSearchBloc>(
          create: (context) => UserSearchBloc(new UserService()),
        ),
      ],
      child: MaterialApp(
        title: 'Travel Tracker',
        initialRoute: '/map',
        routes: {
          '/map': (context) => MapScreen(),
//          //'/search': (context) => SearchPeopleScreen(),
        },
      ),
    );
  }
}
