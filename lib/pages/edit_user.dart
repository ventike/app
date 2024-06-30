import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ventike/api/users.dart';
import 'package:ventike/utils/args.dart';
import 'package:ventike/widgets/navbar.dart';

class EditUserPage extends StatefulWidget {
  const EditUserPage({super.key});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  String userHash = "";
  int role = 2;
  String? profilePicture;

  int id = -1;
  String username = "";
  String email = "";
  String firstName = "";
  String lastName = "";

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  Set<int> userRole = {2};

  bool firstRun = true;

  String errorMessage = "";
  double errorMessagePadding = 0;
  bool saveButtonEnabled = true;
  bool deleteButtonEnabled = true;

  ScrollController scrollController = ScrollController();

  BuildContext getContext() {
    return context;
  }

  void save() {
    String username = usernameController.text;
    String email = emailController.text;
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;

    int role = userRole.first;

    setState(() {
      errorMessage = "";
      errorMessagePadding = 0;
      saveButtonEnabled = false;
    });

    if (username == "" || email == "" || firstName == "" || lastName == "") {
      setState(() {
        errorMessage = "Please fill all fields";
        errorMessagePadding = 15;
        scrollController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
        saveButtonEnabled = true;
      });
      return;
    }

    modifyUser(userHash, id, username, email, firstName, lastName, role).then((res) {
      print(res.statusCode);
      print(res.body);

      if (res.statusCode == 200) {
        Navigator.of(context).popAndPushNamed('/admin', arguments: Arguments(userHash, role, profilePicture));
      }

      setState(() {
        errorMessage = "Something Went Wrong";
        errorMessagePadding = 15;
        scrollController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
        saveButtonEnabled = true;
      });
    });
  }

  void delete() {
    setState(() {
      errorMessage = "";
      errorMessagePadding = 0;
      deleteButtonEnabled = false;
    });

    deleteUser(userHash, id).then((res) {
      print(res.statusCode);
      print(res.body);
      

      if (res.statusCode == 200) {
        Navigator.pop(context);
      }

      setState(() {
        errorMessage = "Something Went Wrong";
        scrollController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
        errorMessagePadding = 15;
        deleteButtonEnabled = true;
      });
    });
  }

  void updateRole(Set<int> roles) {
    setState(() {
      userRole = roles;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (firstRun) {
      final args = ModalRoute.of(context)!.settings.arguments as EditUserArguments;

      userHash = args.userHash;
      role = args.role;
      profilePicture = args.profilePicture;

      // getImageString();

      id = args.id;
      username = args.username;
      email = args.email;
      firstName = args.firstName;
      lastName = args.lastName;

      usernameController.text = username;
      emailController.text = email;
      firstNameController.text = firstName;
      lastNameController.text = lastName;

      userRole = {args.userRole};

      firstRun = false;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(252, 252, 252, 0.08),
        foregroundColor: const Color.fromRGBO(252, 252, 252, 0.95),
        scrolledUnderElevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 39, 39, 39),
      body: Container(
        child: Column(
          children: [
            FractionallySizedBox(
              widthFactor: 1,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(252, 252, 252, 0.08),
                  // boxShadow: [
                  //   BoxShadow(
                  //     blurRadius: 10,
                  //     // spreadRadius: 0.5,
                  //     offset: Offset(0, 5),
                  //     color: Colors.black45
                  //   )
                  // ]
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
                  child: const Text(
                    "Edit User",
                    style: TextStyle(
                      color: Color.fromRGBO(252, 252, 252, 0.95),
                      fontSize: 48,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 25, bottom: 25, right: 20, left: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(252, 252, 252, 0.08),
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: errorMessagePadding),
                              child: Text(
                                errorMessage,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Text(
                                      "Username:",
                                      style: TextStyle(
                                        color: Color.fromRGBO(252, 252, 252, 0.95),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700
                                      ),
                                    )
                                  ),
                                  Theme(
                                    data: ThemeData(
                                      textSelectionTheme: const TextSelectionThemeData(
                                        selectionColor: Color.fromRGBO(252, 252, 252, 0.12),
                                        selectionHandleColor: Color.fromRGBO(252, 252, 252, 0.95)
                                      ),
                                      cupertinoOverrideTheme: const CupertinoThemeData(
                                        primaryColor: Color.fromRGBO(252, 252, 252, 0.95)
                                      )
                                    ),
                                    child: Flexible(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: SizedBox(
                                          height: 40,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 10,
                                                  offset: Offset(0, 5),
                                                  color: Colors.black45
                                                )
                                              ]
                                            ),
                                            child: TextField(
                                              controller: usernameController,
                                              onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                                              textAlignVertical: TextAlignVertical.center,
                                              cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                                              cursorHeight: 20,
                                              style: const TextStyle(
                                                color: Color.fromRGBO(252, 252, 252, 0.7),
                                                height: 2.25,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18,
                                              ),
                                              decoration: const InputDecoration(
                                                contentPadding: EdgeInsets.only(left: 20),
                                                isDense: true,
                                                filled: true,
                                                fillColor: Color.fromRGBO(62, 62, 62, 1),
                                                // hintText: "Username",
                                                // hintStyle: TextStyle(
                                                //   color: Color.fromRGBO(39, 39, 39, 0.75),
                                                // ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                                  borderSide: BorderSide(width: 0, style: BorderStyle.none)
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0.3)),
                                                  borderRadius: BorderRadius.all(Radius.circular(8))
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Text(
                                      "Email:",
                                      style: TextStyle(
                                        color: Color.fromRGBO(252, 252, 252, 0.95),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700
                                      ),
                                    )
                                  ),
                                  Theme(
                                    data: ThemeData(
                                      textSelectionTheme: const TextSelectionThemeData(
                                        selectionColor: Color.fromRGBO(252, 252, 252, 0.12),
                                        selectionHandleColor: Color.fromRGBO(252, 252, 252, 0.95)
                                      ),
                                      cupertinoOverrideTheme: const CupertinoThemeData(
                                        primaryColor: Color.fromRGBO(252, 252, 252, 0.95)
                                      )
                                    ),
                                    child: Flexible(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: SizedBox(
                                          height: 40,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 10,
                                                  offset: Offset(0, 5),
                                                  color: Colors.black45
                                                )
                                              ]
                                            ),
                                            child: TextField(
                                              controller: emailController,
                                              onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                                              textAlignVertical: TextAlignVertical.center,
                                              cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                                              cursorHeight: 20,
                                              style: const TextStyle(
                                                color: Color.fromRGBO(252, 252, 252, 0.7),
                                                height: 2.25,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18,
                                              ),
                                              decoration: const InputDecoration(
                                                contentPadding: EdgeInsets.only(left: 20),
                                                isDense: true,
                                                filled: true,
                                                fillColor: Color.fromRGBO(62, 62, 62, 1),
                                                // hintText: "Username",
                                                // hintStyle: TextStyle(
                                                //   color: Color.fromRGBO(39, 39, 39, 0.75),
                                                // ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                                  borderSide: BorderSide(width: 0, style: BorderStyle.none)
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0.3)),
                                                  borderRadius: BorderRadius.all(Radius.circular(8))
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Text(
                                      "First Name:",
                                      style: TextStyle(
                                        color: Color.fromRGBO(252, 252, 252, 0.95),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700
                                      ),
                                    )
                                  ),
                                  Theme(
                                    data: ThemeData(
                                      textSelectionTheme: const TextSelectionThemeData(
                                        selectionColor: Color.fromRGBO(252, 252, 252, 0.12),
                                        selectionHandleColor: Color.fromRGBO(252, 252, 252, 0.95)
                                      ),
                                      cupertinoOverrideTheme: const CupertinoThemeData(
                                        primaryColor: Color.fromRGBO(252, 252, 252, 0.95)
                                      )
                                    ),
                                    child: Flexible(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: SizedBox(
                                          height: 40,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 10,
                                                  offset: Offset(0, 5),
                                                  color: Colors.black45
                                                )
                                              ]
                                            ),
                                            child: TextField(
                                              controller: firstNameController,
                                              onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                                              textAlignVertical: TextAlignVertical.center,
                                              cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                                              cursorHeight: 20,
                                              style: const TextStyle(
                                                color: Color.fromRGBO(252, 252, 252, 0.7),
                                                height: 2.25,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18,
                                              ),
                                              decoration: const InputDecoration(
                                                contentPadding: EdgeInsets.only(left: 20),
                                                isDense: true,
                                                filled: true,
                                                fillColor: Color.fromRGBO(62, 62, 62, 1),
                                                // hintText: "Username",
                                                // hintStyle: TextStyle(
                                                //   color: Color.fromRGBO(39, 39, 39, 0.75),
                                                // ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                                  borderSide: BorderSide(width: 0, style: BorderStyle.none)
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0.3)),
                                                  borderRadius: BorderRadius.all(Radius.circular(8))
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Text(
                                      "Last Name:",
                                      style: TextStyle(
                                        color: Color.fromRGBO(252, 252, 252, 0.95),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700
                                      ),
                                    )
                                  ),
                                  Theme(
                                    data: ThemeData(
                                      textSelectionTheme: const TextSelectionThemeData(
                                        selectionColor: Color.fromRGBO(252, 252, 252, 0.12),
                                        selectionHandleColor: Color.fromRGBO(252, 252, 252, 0.95)
                                      ),
                                      cupertinoOverrideTheme: const CupertinoThemeData(
                                        primaryColor: Color.fromRGBO(252, 252, 252, 0.95)
                                      )
                                    ),
                                    child: Flexible(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: SizedBox(
                                          height: 40,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 10,
                                                  offset: Offset(0, 5),
                                                  color: Colors.black45
                                                )
                                              ]
                                            ),
                                            child: TextField(
                                              controller: lastNameController,
                                              onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                                              textAlignVertical: TextAlignVertical.center,
                                              cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                                              cursorHeight: 20,
                                              style: const TextStyle(
                                                color: Color.fromRGBO(252, 252, 252, 0.7),
                                                height: 2.25,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18,
                                              ),
                                              decoration: const InputDecoration(
                                                contentPadding: EdgeInsets.only(left: 20),
                                                isDense: true,
                                                filled: true,
                                                fillColor: Color.fromRGBO(62, 62, 62, 1),
                                                // hintText: "Username",
                                                // hintStyle: TextStyle(
                                                //   color: Color.fromRGBO(39, 39, 39, 0.75),
                                                // ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                                  borderSide: BorderSide(width: 0, style: BorderStyle.none)
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0.3)),
                                                  borderRadius: BorderRadius.all(Radius.circular(8))
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Text(
                                      "Role:",
                                      style: TextStyle(
                                        color: Color.fromRGBO(252, 252, 252, 0.95),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700
                                      ),
                                    )
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: SizedBox(
                                        height: 50,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     blurRadius: 10,
                                            //     offset: Offset(0, 5),
                                            //     color: Colors.black45
                                            //   )
                                            // ]
                                          ),
                                          child: SegmentedButton<int>(
                                            segments: () {
                                              List<ButtonSegment<int>> res = [];
                                              if (role == 0) {
                                                res.add(
                                                  ButtonSegment<int>(
                                                    value: 0,
                                                    icon: Icon(
                                                      Icons.manage_accounts_rounded,
                                                      size: 20,
                                                    ),
                                                    // label: Text("Business")
                                                  )
                                                );
                                              }

                                              res.add(
                                                ButtonSegment<int>(
                                                  value: 1,
                                                  icon: Icon(
                                                    Icons.people_alt_rounded,
                                                    size: 20,
                                                  ),
                                                  // label: Text("Community")
                                                ),
                                              );

                                              res.add(
                                                ButtonSegment<int>(
                                                  value: 2,
                                                  icon: Icon(
                                                    Icons.account_circle_rounded,
                                                    size: 20,
                                                  ),
                                                  // label: Text("Community")
                                                )
                                              );

                                              return res;
                                            }(),
                                            selected: userRole,
                                            onSelectionChanged: updateRole,
                                            showSelectedIcon: false,
                                            style: SegmentedButton.styleFrom(
                                              foregroundColor: Color.fromRGBO(252, 252, 252, 0.7),
                                              backgroundColor: Color.fromRGBO(252, 252, 252, 0.08),
                                              selectedForegroundColor: Color.fromRGBO(252, 252, 252, 0.95),
                                              selectedBackgroundColor: Color.fromRGBO(252, 252, 252, 0.2),
                                              fixedSize: Size.fromHeight(50),
                                              padding: EdgeInsets.all(0)
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: OutlinedButton(
                                          onPressed: saveButtonEnabled ? save : null,
                                          // onPressed: () {},
                                          style: OutlinedButton.styleFrom(
                                            padding: EdgeInsets.only(left: 20, right: 20),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            side: BorderSide(
                                              color: Color.fromRGBO(107, 212, 37, 0.95)
                                            )
                                          ),
                                          child: Text(
                                            "Save",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Color.fromRGBO(107, 212, 37, 0.95),
                                            ),
                                          ),
                                        ),
                                      ),
                                      OutlinedButton(
                                        onPressed: () { Navigator.pop(context); },
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.only(left: 15, right: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          side: BorderSide(
                                            color: Color.fromRGBO(252, 252, 252, 0.95)
                                          )
                                        ),
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color.fromRGBO(252, 252, 252, 0.95),
                                          ),
                                        ),
                                      )
                                    ]
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: deleteButtonEnabled ? delete : null,
                                  // onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.only(left: 15, right: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    side: BorderSide(
                                      color: Color.fromRGBO(230, 57, 70, 0.95)
                                    )
                                  ),
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color.fromRGBO(230, 57, 70, 0.95),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: generateNavigationBar(userHash, role, profilePicture, setState, getContext)
    );
  }
}