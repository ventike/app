import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ventike/pages/cipher.dart';
import 'package:ventike/utils/vars.dart';
import 'package:ventike/pages/dashboard.dart';
import 'package:ventike/utils/args.dart';

void navbarCallback(int index, String userHash, int role, String? profilePicture, BuildContext Function() getContext) {
  navbarIndex = index;
  if (index == 0) {
    Navigator.of(getContext()).pushNamedAndRemoveUntil(routes[index], (route) => false, arguments: Arguments(userHash, role, profilePicture));
  } else if (index < routes.length) {
    if (index >= 3 && role == 2) {
      Navigator.of(getContext()).pushNamed(routes[index + 1], arguments: Arguments(userHash, role, profilePicture));
    } else {
      Navigator.of(getContext()).pushNamed(routes[index], arguments: Arguments(userHash, role, profilePicture));
    }
      
  }
}

BottomNavigationBar generateNavigationBar(String userHash, int role, String? profilePicture, void Function(void Function() fn) setState, BuildContext Function() getContext) {
  return BottomNavigationBar(
    currentIndex: navbarIndex,
    type: BottomNavigationBarType.fixed,
    showSelectedLabels: false,
    showUnselectedLabels: false,
    backgroundColor: const Color.fromRGBO(252, 252, 252, 0.08),
    iconSize: 50,
    onTap: (index) {setState(() {navbarCallback(index, userHash, role, profilePicture, getContext);});},
    selectedIconTheme: IconThemeData(
      color: Color.fromRGBO(252, 252, 252, 0.95),
      // weight: 500
    ),
    unselectedIconTheme: IconThemeData(
      color: Color.fromRGBO(252, 252, 252, 0.5),
    ),
    items: () {
      if (role == 2) {
        return [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.handshake_rounded), label: "Partners"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: "Events"),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onLongPress: () { Navigator.of(getContext()).pushNamed("/cipher", arguments: Arguments(userHash, role, profilePicture)); },
              onTap: () {Navigator.of(getContext()).pushNamedAndRemoveUntil("/login", (route) => false);},
              child: CircleAvatar()
            ),
            label: "Account"
          )
        ];
      } 
      return [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.handshake_rounded), label: "Partners"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: "Events"),
        BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_rounded), label: "Admin"),
        BottomNavigationBarItem(
          icon: GestureDetector(
            onLongPress: () { Navigator.of(getContext()).pushNamed("/cipher", arguments: Arguments(userHash, role, profilePicture)); },
            onTap: () {Navigator.of(getContext()).pushNamedAndRemoveUntil("/login", (route) => false);},
            child: CircleAvatar()
          ),
          label: "Account"
        )
      ];
    }()
  );
} 