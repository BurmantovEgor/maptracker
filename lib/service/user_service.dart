import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../bloc/user/userSearch_event.dart';
import '../bloc/user/user_event.dart';
import '../data/models/user.dart';

class UserService {
  final Dio dio;

  UserService()
      : dio = Dio(
          BaseOptions(
           // baseUrl: "https://192.168.3.38:7042",
            baseUrl: "https://192.168.3.10:7042",
          ),
        ) {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  Future<List<String>> searchUser(FetchUsersEvent event) async {
    try {
      final response = await dio.get(
        '/api/users/search',
        queryParameters: {'username': event.query},
      );
      List<String> users = [];
      if (response.statusCode == 200) {
        final List<dynamic> results = response.data;
        users = results.map((e) => e['userName'] as String).toList();
        return users;
      } else {
        return users;
      }
    } catch (e) {
      print('ErrorLoadPoints: $e');
      throw Exception('Error while fetching data');
    }
  }
  Future<User> registerUser(RegisterUserEvent event) async {
    try {
      final response = await dio.post(
        '/api/users/register',
        data: {
          "userName": event.username,
          "email": event.email,
          "password": event.password,
        },
      );
      if (response.statusCode == 200) {
        final tempUser = User(
            id: 0,
            email: event.email,
            username: event.username,
            jwt: "",
            isAuthorized: true);
        return tempUser;
      } else {
        return User(
            id: -1,
            email: event.email,
            username: event.username,
            jwt: "",
            isAuthorized: false);
      }
    } catch (e) {
      print('ErrorLoadPoints: $e');
      throw Exception('Error while fetching data');
    }
  }
  Future<User> loginUser(LoginUserEvent event) async {
    try {
      print('email: ${event.email} password: ${event.password}');
      if (event.email.trim().isNotEmpty && event.password.isNotEmpty) {
        final response = await dio.post(
          '/api/users/login',
          data: {
            "email": event.email,
            "password": event.password,
          },
          options: Options(
            headers: {
              "Content-Type": "application/json",
            },
          ),
        );
        print('responceCode: ${response.statusCode}');
        if (response.statusCode == 200) {
          final String token = response.data['token'];
          final tempUser = User(
              id: 0,
              email: event.email,
              username: "test",
              jwt: token,
              isAuthorized: true);
          return tempUser;
        } else {
          return User(
              id: -1,
              email: event.email,
              username: "",
              jwt: "",
              isAuthorized: false);
        }
      } else {
        return User(
            id: -1,
            email: event.email,
            username: "",
            jwt: "",
            isAuthorized: false);
      }
    } catch (e) {
      print('ErrorLoadPoints: $e');
      throw Exception('Error while fetching data');
    }
  }
}
