import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ventike/api/dashboard_data.dart';
import 'package:ventike/utils/args.dart';
import 'package:ventike/utils/vars.dart';
import 'package:ventike/widgets/navbar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String userHash = "";
  int role = 2;
  String? profilePicture;

  bool messageExists = false;
  String? messageTitle;
  String? message;
  int? messageIcon;

  BuildContext getContext() {
    return context;
  }

  Future<void> getData() async {
    Response res = await requestDashboardData(userHash);
    if (this.mounted) {
      if (res.statusCode == 200) {
        setState(() {
          print(res.body);
          final data = jsonDecode(res.body);

          messageExists = data[1]["message"] != null;
          
          if (messageExists) {
            messageTitle = data[1]["message_title"];
            message = data[1]["message"];
            messageIcon = data[1]["message_icon"];
          }
        });
      } else {
        // TBD - Something Went Wrong
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Arguments;
    userHash = args.userHash;
    role = args.role;
    profilePicture = args.profilePicture;

    setState(() {
      navbarIndex = 0;
    });

    getData();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 39, 39, 39),
        foregroundColor: const Color.fromRGBO(252, 252, 252, 0.95),
        scrolledUnderElevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 39, 39, 39),
      body: Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: () {
            List<Widget> res = [];

            res.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "Dashboard",
                  style: TextStyle(
                    color: Color.fromRGBO(252, 252, 252, 0.95),
                    fontSize: 48,
                    fontWeight: FontWeight.w600
                  ),
                ),
              )
            );

            if (messageExists) {
              res.add(
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: messageIconColorsPartialFaded[messageIcon!]
                    ),
                    color: messageIconColorsFaded[messageIcon!]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Icon(
                                messageIcons[messageIcon!],
                                color: messageIconColorsPartialFaded[messageIcon!],
                                size: 18,
                              ),
                            ),
                            Text(
                              messageTitle!,
                              style: TextStyle(
                                color: messageIconColorsPartialFaded[messageIcon!],
                                fontSize: 18,
                                fontWeight: FontWeight.w600
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          child: Text(
                            message!,
                            style: TextStyle(
                              color: messageIconColorsPartialFaded[messageIcon!],
                              fontSize: 12,
                              fontWeight: FontWeight.w300
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              );
            }

            return res;
          }(),
        ),
      ),
      bottomNavigationBar: generateNavigationBar(userHash, role, profilePicture, setState, getContext)
    );
  }
}