import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ventike/api/users.dart';
import 'package:http/http.dart' as http;
import 'package:ventike/pages/dashboard.dart';
import 'package:ventike/utils/args.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String errorMessage = "";
  double errorMessagePadding = 0;
  bool buttonEnabled = true;

  void login() {
    String username = usernameController.text;
    String password = passwordController.text;

    print(username);
    print(password);

    setState(() {
      errorMessage = "";
      errorMessagePadding = 0;
      buttonEnabled = false;
    });

    if (username == "" || password == "") {
      setState(() {
        errorMessage = "Please fill all fields";
        errorMessagePadding = 10;
        buttonEnabled = true;
      });
      return;
    }

    requestLogin(username, password).then((res) {
      print(res.statusCode);
      print(res.body);
      

      if (res.statusCode == 200) {
        final userData = jsonDecode(res.body) as Map<String, dynamic>;
        Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false, arguments: Arguments(userData["user_hash"], userData["role"], userData["profile_picture"]));
      } else if (res.statusCode == 401) {
        setState(() {
          errorMessage = "Invalid Credentials";
          errorMessagePadding = 10;
          buttonEnabled = true;
        });
        return;
      }

      setState(() {
        errorMessage = "Something Went Wrong";
        errorMessagePadding = 10;
        buttonEnabled = true;
      });
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 39, 39, 39),
        body: Center(
          child: Container(
            height: 350,
            width: 325,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(252, 252, 252, 0.08),
              borderRadius: BorderRadius.circular(20),
              // boxShadow: const [
              //   BoxShadow(
              //     blurRadius: 15,
              //     color: Colors.red,
              //     // color: Color.fromRGBO(39, 39, 39, 0.9),
              //   )
              // ]
            ),
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.9,
                  child: Image.asset('assets/images/logoandtext.png'),
                  // child: SvgPicture.asset(
                  //   'assets/images/logoandtext.svg',
                  //   semanticsLabel: 'Logo',
                  //   fit: BoxFit.fitWidth,
                  //   // height: 82
                  // ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: errorMessagePadding),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 15,
                      fontWeight: FontWeight.w600
                    ), 
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        spreadRadius: 0,
                        // color: Colors.red
                        color: Color.fromRGBO(39, 39, 39, 0.9),
                      )
                    ]
                  ),
                  child: Theme(
                    data: ThemeData(
                      textSelectionTheme: const TextSelectionThemeData(
                        selectionColor: Color.fromRGBO(107, 212, 37, 0.95),
                        selectionHandleColor: Color.fromRGBO(107, 212, 37, 0.95)
                      ),
                      cupertinoOverrideTheme: const CupertinoThemeData(
                        primaryColor: Color.fromRGBO(107, 212, 37, 0.95)
                      )
                    ),
                    child: FractionallySizedBox(
                      widthFactor: 0.89,
                      child: TextField(
                        controller: usernameController,
                        onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                        textAlignVertical: TextAlignVertical.center,
                        cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                        cursorHeight: 20,
                        style: const TextStyle(
                          color: Color.fromRGBO(39, 39, 39, 0.95),
                          height: 2.25,
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 20),
                          isDense: true,
                          filled: true,
                          fillColor: Color.fromARGB(255, 252, 252, 252),
                          hintText: "Username",
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(39, 39, 39, 0.75),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(100))
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromRGBO(107, 212, 37, 0.95)),
                            borderRadius: BorderRadius.all(Radius.circular(100))
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        spreadRadius: 0,
                        // color: Colors.red
                        color: Color.fromRGBO(39, 39, 39, 0.9),
                      )
                    ]
                  ),
                  child: Theme(
                    data: ThemeData(
                      textSelectionTheme: const TextSelectionThemeData(
                        selectionColor: Color.fromRGBO(107, 212, 37, 0.95),
                        selectionHandleColor: Color.fromRGBO(107, 212, 37, 0.95)
                      ),
                      cupertinoOverrideTheme: const CupertinoThemeData(
                        primaryColor: Color.fromRGBO(107, 212, 37, 0.95)
                      )
                    ),
                    child: FractionallySizedBox(
                      widthFactor: 0.89,
                      child: TextField(
                        controller: passwordController,
                        onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                        textAlignVertical: TextAlignVertical.center,
                        cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                        cursorHeight: 20,
                        obscureText: true,
                        style: const TextStyle(
                          color: Color.fromRGBO(39, 39, 39, 0.95),
                          height: 2.25,
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 20),
                          isDense: true,
                          filled: true,
                          fillColor: Color.fromARGB(255, 252, 252, 252),
                          hintText: "Password",
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(39, 39, 39, 0.75),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(100))
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromRGBO(107, 212, 37, 0.95)),
                            borderRadius: BorderRadius.all(Radius.circular(100))
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: OutlinedButton(
                    onPressed: buttonEnabled ? login : null,
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      side: const BorderSide(color: Color.fromRGBO(107, 212, 37, 0.95)),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Color.fromRGBO(252, 252, 252, 0.95),
                        height: 2.25,
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                      ),
                    )
                  ),
                )
              ],
            ),
        ),
              )
    );
  }
}