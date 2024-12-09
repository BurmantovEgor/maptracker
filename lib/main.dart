// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/data/repositories/current_location.dart';
import 'bloc/point/point_block.dart';
import 'bloc/ui/screens/map_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      home: BlocProvider(
        create: (context) => PointBloc(), // Здесь мы создаем PointBloc
        child: MapScreen(),
      ),
    );
  }
}
