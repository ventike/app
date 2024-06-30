import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ventike/pages/cipher.dart';
import 'package:ventike/pages/admin.dart';
import 'package:ventike/pages/dashboard.dart';
import 'package:ventike/pages/edit_event.dart';
import 'package:ventike/pages/edit_partner.dart';
import 'package:ventike/pages/edit_user.dart';
import 'package:ventike/pages/events.dart';
import 'package:ventike/pages/login.dart';
import 'package:ventike/pages/new_event.dart';
import 'package:ventike/pages/new_partner.dart';
import 'package:ventike/pages/partners.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Ventike",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Comfortaa"),
      home: const LoginPage(),
      routes: {
        "/login": (context) => LoginPage(),
        "/dashboard": (context) => DashboardPage(),
        "/partners": (context) => PartnersPage(),
        "/newpartner": (context) => NewPartnerPage(),
        "/editpartner": (context) => EditPartnerPage(),
        "/events": (context) => EventsPage(),
        "/newevent": (context) => NewEventPage(),
        "/editevent": (context) => EditEventPage(),
        "/admin": (context) => AdminPage(),
        "/edituser": (context) => EditUserPage(),
        "/cipher": (context) => CipherPage(),
      },
    );
  }
}
