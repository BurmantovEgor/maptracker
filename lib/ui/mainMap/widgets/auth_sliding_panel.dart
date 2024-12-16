import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../bloc/user/user_block.dart';
import '../../../bloc/user/user_event.dart';
import '../../../bloc/user/user_state.dart';
import '../../../data/models/user.dart';

class SlidingPanelWidget extends StatefulWidget {
  final PanelController panelController;
  final User currentUser;

  const SlidingPanelWidget(
      {required this.panelController, required this.currentUser, Key? key})
      : super(key: key);

  @override
  _SlidingPanelWidgetState createState() => _SlidingPanelWidgetState();
}

class _SlidingPanelWidgetState extends State<SlidingPanelWidget> {
  late PanelController panelController;

  @override
  void initState() {
    super.initState();
    panelController = widget.panelController;
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isObscured = true;

  int currentPage = 0;
  bool isRegisterMode = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailContoller = TextEditingController();
  TextEditingController passwordContoller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    UserBloc userBloc = context.read<UserBloc>();

    return SlidingUpPanel(
      controller: panelController,
      minHeight: 0,
      maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      backdropEnabled: true,
      backdropTapClosesPanel: true,
      renderPanelSheet: false,
      panel: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Закрываем клавиатуру
        },
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: !widget.currentUser.isAuthorized
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: Center(
                            child: Container(
                              width: 50,
                              height: 7,
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isRegisterMode =
                                      false; // Переключаем на режим Входа
                                });
                              },
                              child: Text(
                                'Вход',
                                style: TextStyle(
                                  color: !isRegisterMode
                                      ? Colors.black
                                      : Colors.grey,
                                  fontSize: 25,
                                  fontFamily: 'Roboto', // Строгий шрифт
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isRegisterMode =
                                      true; // Переключаем на режим Регистрации
                                });
                              },
                              child: Text(
                                'Регистрация',
                                style: TextStyle(
                                  color: isRegisterMode
                                      ? Colors.black
                                      : Colors.grey,
                                  fontSize: 25,
                                  fontFamily: 'Roboto', // Строгий шрифт
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Visibility(
                          visible: isRegisterMode,
                          child: TextField(
                            controller: nameController,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto', // Строгий шрифт
                            ),
                            decoration: InputDecoration(
                              hintText: 'Логин',
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              contentPadding: const EdgeInsets.all(12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              counterText: '', // Убираем счетчик символов
                            ),
                            maxLength: 20,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: emailContoller,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto', // Строгий шрифт
                          ),
                          decoration: InputDecoration(
                            hintText: 'Электронная почта',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: passwordContoller,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                          obscureText: isObscured,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isObscured = !isObscured;
                                });
                              },
                              icon: Icon(
                                isObscured
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                            ),
                            counterText: '',
                            hintText: 'Пароль',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          maxLength: 40,
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: SizedBox(
                            height: 50,
                            width: 150,
                            child: FloatingActionButton(
                              heroTag: 'LogIn/Register_Button',
                              elevation: 0,
                              backgroundColor: Colors.grey.shade200,
                              child: Text(
                                isRegisterMode ? "Создать аккаунт" : "Вход",
                                style: const TextStyle(color: Colors.black87),
                              ),
                              onPressed: () {
                                if (!isRegisterMode) {
                                  if (emailContoller.text.trim().isNotEmpty &&
                                      passwordContoller.text
                                          .trim()
                                          .isNotEmpty) {
                                    userBloc.add(LoginUserEvent(
                                        email: emailContoller.text.trim(),
                                        password:
                                            passwordContoller.text.trim()));
                                    FocusScope.of(context)
                                        .unfocus();
                                    panelController.close();
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            "Для продолжения необходимо заполнить данные");
                                  }
                                } else {
                                  if (nameController.text.trim().isNotEmpty &&
                                      emailContoller.text.trim().isNotEmpty &&
                                      passwordContoller.text
                                          .trim()
                                          .isNotEmpty) {
                                    userBloc.add(RegisterUserEvent(
                                        email: emailContoller.text,
                                        password: passwordContoller.text,
                                        username: nameController.text));
                                    userBloc.stream.listen((userState) {
                                      if (userState is UserRegisteredState) {
                                        userBloc.add(LoginUserEvent(
                                            email: userState.user.email,
                                            password: passwordContoller.text));
                                        nameController.text = '';
                                        emailContoller.text = '';
                                        passwordContoller.text = '';
                                        FocusScope.of(context)
                                            .unfocus(); // Закрываем клавиатуру
                                        panelController.close();
                                      }
                                    });
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            "Для продолжения необходимо заполнить данные");
                                  }
                                }
                              },
                            ),
                          ),
                        )
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          const Text(
                            'Текущий пользователь',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                          Text(
                            widget.currentUser.email,
                            style: const TextStyle(
                              fontSize: 25,
                            ),
                          ),
                          Text(
                            widget.currentUser.username,
                            style: const TextStyle(
                              fontSize: 25,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Center(
                              child: SizedBox(
                            height: 50,
                            width: 150,
                            child: FloatingActionButton(
                              heroTag: 'LogOut_Button',
                              elevation: 0,
                              backgroundColor: Colors.grey.shade200,
                              onPressed: () async {
                                userBloc.add(LogoutUserEvent());
                                panelController.close();
                              },
                              child: const Text(
                                "Выход",
                                style: TextStyle(
                                    color: Colors.black87),
                              ),
                            ),
                          ))
                        ])),
        ),
      ),
    );

/*
    return SlidingUpPanel(
      controller: panelController,
      minHeight: 0,
      maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      backdropEnabled: true,
      backdropTapClosesPanel: true,
      renderPanelSheet: false,
      panel: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: !widget.currentUser.isAuthorized
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: Center(
                        child: Container(
                          width: 50,
                          height: 7,
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isRegisterMode =
                                  false; // Переключаем на режим Входа
                            });
                          },
                          child: Text(
                            'Вход',
                            style: TextStyle(
                              color:
                                  !isRegisterMode ? Colors.black : Colors.grey,
                              fontSize: 25,
                              fontFamily: 'Roboto', // Строгий шрифт
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isRegisterMode =
                                  true; // Переключаем на режим Регистрации
                            });
                          },
                          child: Text(
                            'Регистрация',
                            style: TextStyle(
                              color:
                                  isRegisterMode ? Colors.black : Colors.grey,
                              fontSize: 25,
                              fontFamily: 'Roboto', // Строгий шрифт
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Visibility(
                      visible: isRegisterMode,
                      child: TextField(
                        controller: nameController,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto', // Строгий шрифт
                        ),
                        decoration: InputDecoration(
                          hintText: 'Логин',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.all(12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          counterText: '', // Убираем счетчик символов
                        ),
                        maxLength: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailContoller,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto', // Строгий шрифт
                      ),
                      decoration: InputDecoration(
                        hintText: 'Электронная почта',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordContoller,

                      style:  const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                      obscureText: isObscured,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isObscured =
                                  !isObscured;
                            });
                          },
                          icon: Icon(
                            isObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                        ),
                        counterText: '',
                        hintText: 'Пароль',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLength: 40,
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: SizedBox(
                        height: 50,
                        width: 150,
                        child: FloatingActionButton(
                          elevation: 0,
                          backgroundColor: Colors.grey.shade200,
                          child: Text(
                            isRegisterMode ? "Создать аккаунт" : "Вход",
                            style: const TextStyle(color: Colors.black87),
                          ),
                          onPressed: () {
                            if (!isRegisterMode) {
                              if (emailContoller.text.trim().isNotEmpty &&
                                  passwordContoller.text.trim().isNotEmpty) {
                                userBloc.add(LoginUserEvent(
                                    email: emailContoller.text.trim(),
                                    password: passwordContoller.text.trim()));
                                panelController.close();
                              } else {
                                Fluttertoast.showToast(
                                    msg:
                                        "Для продолжения необходимо заполнить данные");
                              }
                            } else {
                              if (nameController.text.trim().isNotEmpty &&
                                  emailContoller.text.trim().isNotEmpty &&
                                  passwordContoller.text.trim().isNotEmpty) {
                                userBloc.add(RegisterUserEvent(
                                    email: emailContoller.text,
                                    password: passwordContoller.text,
                                    username: nameController.text));
                                userBloc.stream.listen((userState) {
                                  if (userState is UserRegisteredState) {
                                    userBloc.add(LoginUserEvent(
                                        email: userState.user.email,
                                        password: passwordContoller.text));
                                    panelController.close();
                                  }
                                });
                              } else {
                                Fluttertoast.showToast(
                                    msg:
                                        "Для продолжения необходимо заполнить данные");
                              }
                            }
                          },
                        ),
                      ),
                    )
                  ],
                )
              : FloatingActionButton(
                  onPressed: () async {
                    userBloc.add(LogoutUserEvent());
                    panelController.close();
                  },
                  child: const Text("Выход"),
                ),
        ),
      ),
    );
*/
  }
}
