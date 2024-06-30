import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:ventike/api/admin.dart';
import 'package:ventike/api/organization.dart';
import 'package:ventike/api/partners_data.dart';
import 'package:ventike/utils/args.dart';
import 'package:ventike/utils/vars.dart';
import 'package:ventike/widgets/navbar.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String userHash = "";
  int role = 2;
  String? profilePicture;

  List<dynamic> allUsers = [];
  List<dynamic> visibleUsers = [];
  String searchTerm = "";

  TextEditingController organizationNameController = TextEditingController();

  Map<String, dynamic> organization = {};
  bool organizationMessageExists = false;
  TextEditingController organizationMessageTitleController = TextEditingController();
  TextEditingController organizationMessageController = TextEditingController();
  int organizationMessageIcon = 0;

  bool saveButtonEnabled = true;

  String errorMessage = "";
  double errorMessagePadding = 0;

  bool firstRun = true;

  BuildContext getContext() {
    return context;
  }

  Future<void> refreshData() async {
    Response res = await requestAdminData(userHash);
    if (res.statusCode == 200) {
      setState(() {
        print(res.body);
        final data = jsonDecode(res.body) as List<dynamic>;
        allUsers = data[0];
        visibleUsers = allUsers;
        searchTerm = "";
        organization = data[1];
        organizationNameController.text = organization["name"];

        if (organization["message"] != null) {
          organizationMessageExists = true;
          organizationMessageTitleController.text = organization["message_title"];
          organizationMessageController.text = organization["message"];
          organizationMessageIcon = organization["message_icon"];
        } else {
          organizationMessageExists = false;
        }
      });
    } else {
      // TBD - Something Went Wrong
    }
  }

  void saveOrganization() {
    String name = organizationNameController.text;
    String organizationMessageTitle = organizationMessageTitleController.text;
    String organizationMessage = organizationMessageController.text;

    setState(() {
      errorMessage = "";
      errorMessagePadding = 0;
      saveButtonEnabled = false;
    });

    if (name == "") {
      setState(() {
        errorMessage = "Please fill all fields";
        errorMessagePadding = 15;
        saveButtonEnabled = true;
      });
      return;
    }

    if (organizationMessageExists && (organizationMessageTitle == "" || organizationMessage == "")) {
      setState(() {
        errorMessage = "Please fill all fields";
        errorMessagePadding = 15;
        saveButtonEnabled = true;
      });
      return;
    }

    modifyOrganization(userHash, name, organizationMessageExists ? organizationMessageTitle : null, organizationMessageExists ? organizationMessage : null, organizationMessageExists ? organizationMessageIcon : null).then((res) {
      print(res.statusCode);
      print(res.body);

      if (res.statusCode == 200) {
        setState(() {
          saveButtonEnabled = true;
        });
        return;
      }

      setState(() {
        errorMessage = "Something Went Wrong";
        errorMessagePadding = 15;
        saveButtonEnabled = true;
      });
    });
  }

  void search(String value) {
    searchTerm = value;
    setState(() {
      visibleUsers = [];
    });

    final terms = value.split(" ");
    List<String> cleanedTerms = [];

    for (String term in terms) {
      if (term.trim().isNotEmpty) {
        cleanedTerms.add(term.trim().toLowerCase());
      }
    }

    for (final user in allUsers) {
      bool canAdd = true;

      for (String term in cleanedTerms) {
        bool termExists = false;

        if (user["username"].toLowerCase().contains(term) || user["first_name"].toLowerCase().contains(term) || user["last_name"].toLowerCase().contains(term)) {
          termExists = true;
        }

        if (!termExists) {
          canAdd = false;
          break;
        }
      }

      if (canAdd) {
        setState(() {
          visibleUsers.add(user); 
        });
      }
    }
  }

  Future openSearch() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // title: Text("Search"),
          content: TextField(
            controller: TextEditingController()..text = searchTerm,
            onChanged: search,
            decoration: InputDecoration(
              suffixIcon: Icon(
                Icons.search_rounded,
                color: Color.fromRGBO(252, 252, 252, 0.7),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromRGBO(252, 252, 252, 0.7)
                )
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromRGBO(252, 252, 252, 0.7)
                )
              ),
            ),
            style: TextStyle(
              color: Color.fromRGBO(252, 252, 252, 0.95),
              fontSize: 24
            ),
          ),
          backgroundColor: Color.fromRGBO(56, 56, 56, 1),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Arguments;
    userHash = args.userHash;
    role = args.role;
    profilePicture = args.profilePicture;

    setState(() {
      navbarIndex = 3;
    });

    if (firstRun) {
      refreshData();
      firstRun = false;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 39, 39, 39),
        foregroundColor: const Color.fromRGBO(252, 252, 252, 0.95),
        scrolledUnderElevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 39, 39, 39),
      body: Container(
        padding: const EdgeInsets.only(top: 25, bottom: 25, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: FractionallySizedBox(
                  widthFactor: 1,
                  child: Text(
                    "Admin",
                    style: TextStyle(
                      color: Color.fromRGBO(252, 252, 252, 0.95),
                      fontSize: 48,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: FractionallySizedBox(
                  widthFactor: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(50, 50, 50, 1),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 10,
                          offset: Offset(0, 5)
                        )
                      ]
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.corporate_fare_rounded,
                                  color: Color.fromRGBO(252, 252, 252, 0.95),
                                  size: 36,
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  "Organization Information",
                                  style: TextStyle(
                                    color: Color.fromRGBO(252, 252, 252, 0.95),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700
                                  ),
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: errorMessagePadding),
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
                            padding: const EdgeInsets.only(top: 15, bottom: 10),
                            child: TextField(
                              controller: organizationNameController,
                              onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                              cursorHeight: 20,
                              style: const TextStyle(
                                color: Color.fromRGBO(252, 252, 252, 0.95),
                                height: 2.25,
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(left: 20),
                                isDense: true,
                                filled: true,
                                fillColor: Color.fromRGBO(60, 60, 60, 1),
                                hintText: "Organization Name",
                                hintStyle: TextStyle(
                                  color: Color.fromRGBO(252, 252, 252, 0.5),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0)),
                                  borderRadius: BorderRadius.all(Radius.circular(12))
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0.3)),
                                  borderRadius: BorderRadius.all(Radius.circular(12))
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(60, 60, 60, 1),
                              borderRadius: BorderRadius.circular(12)
                            ),
                            child: FractionallySizedBox(
                              widthFactor: 1,
                              child: Column(
                                children: () {
                                  List<Widget> res = [];
                                  res.add(
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Text(
                                            "Message",
                                            style: TextStyle(
                                              color: Color.fromRGBO(252, 252, 252, 0.9),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600
                                            ),
                                          ),
                                        ),
                                        Theme(
                                          data: ThemeData(
                                            checkboxTheme: CheckboxThemeData(
                                              checkColor: WidgetStatePropertyAll(Color.fromRGBO(252, 252, 252, 0.95)),
                                              fillColor: WidgetStatePropertyAll(Color.fromRGBO(252, 252, 252, 0.12)),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(4)
                                              ),
                                              side: BorderSide(
                                                color: Color.fromRGBO(252, 252, 252, 0)
                                              )
                                            )
                                          ),
                                          child: Checkbox(
                                            value: organizationMessageExists,
                                            onChanged: (val) {
                                              setState(() {
                                                organizationMessageExists = val ?? organizationMessageExists;
                                              });
                                            }
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                  
                                  if (organizationMessageExists) {
                                    res.add(
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 10),
                                              child: Text(
                                                "Title:",
                                                style: TextStyle(
                                                  color: Color.fromRGBO(252, 252, 252, 0.8),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: TextField(
                                                controller: organizationMessageTitleController,
                                                onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                                                textAlignVertical: TextAlignVertical.center,
                                                cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                                                cursorHeight: 20,
                                                style: const TextStyle(
                                                  color: Color.fromRGBO(252, 252, 252, 0.95),
                                                  height: 2.25,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                ),
                                                decoration: const InputDecoration(
                                                  contentPadding: EdgeInsets.only(left: 20),
                                                  isDense: true,
                                                  filled: true,
                                                  fillColor: Color.fromRGBO(252, 252, 252, 0.05),
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0)),
                                                    borderRadius: BorderRadius.all(Radius.circular(12))
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0.3)),
                                                    borderRadius: BorderRadius.all(Radius.circular(12))
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    );
          
                                    res.add(
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 10),
                                              child: Text(
                                                "Message:",
                                                style: TextStyle(
                                                  color: Color.fromRGBO(252, 252, 252, 0.8),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: TextField(
                                                controller: organizationMessageController,
                                                onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                                                textAlignVertical: TextAlignVertical.center,
                                                cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                                                cursorHeight: 20,
                                                style: const TextStyle(
                                                  color: Color.fromRGBO(252, 252, 252, 0.95),
                                                  height: 2.25,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                ),
                                                minLines: 2,
                                                maxLines: 2,
                                                decoration: const InputDecoration(
                                                  contentPadding: EdgeInsets.only(left: 20),
                                                  isDense: true,
                                                  filled: true,
                                                  fillColor: Color.fromRGBO(252, 252, 252, 0.05),
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0)),
                                                    borderRadius: BorderRadius.all(Radius.circular(12))
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0.3)),
                                                    borderRadius: BorderRadius.all(Radius.circular(12))
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    );
          
                                    res.add(
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: () {
                                            List<Widget> icons = [];
          
                                            icons.add(
                                              Padding(
                                                padding: const EdgeInsets.only(right: 10),
                                                child: Text(
                                                  "Icons",
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(252, 252, 252, 0.8),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600
                                                  ),
                                                ),
                                              ),
                                            );
          
                                            for (int i = 0; i < messageIcons.length; i++) {
                                              icons.add(
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      // borderRadius: BorderRadius.circular(100),
                                                      shape: BoxShape.circle,
                                                      // color: Colors.green,
                                                      gradient: () {
                                                        if (organizationMessageIcon == i) {
                                                          return RadialGradient(
                                                            colors: [
                                                              Color.fromRGBO(252, 252, 252, 0.2),
                                                              Color.fromRGBO(252, 252, 252, 0.1)
                                                            ]
                                                          );
                                                        }
                                                        return null;
                                                      }()
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    child: IconButton(
                                                      onPressed: () { setState(() { organizationMessageIcon = i; }); },
                                                      style: IconButton.styleFrom(
                                                        padding: EdgeInsets.zero
                                                        // shape: CircleBorder(
                                                        //   side: BorderSide(color: Colors.red)
                                                        // )
                                                      ),
                                                      icon: Icon(
                                                        messageIcons[i],
                                                        color: messageIconColors[i],
                                                      ),
                                                      iconSize: 22,
                                                    ),
                                                  ),
                                                )
                                              );
                                            }
          
                                            return icons;
                                          }(),
                                        ),
                                      )
                                    );
                                  }
                              
                                  return res;
                                }(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: OutlinedButton(
                              onPressed: saveButtonEnabled ? saveOrganization : null,
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
                          )
                        ]
                      )
                    )
                  ),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(50, 50, 50, 1),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 10,
                        offset: Offset(0, 5)
                      )
                    ]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Icon(
                                        Icons.group_rounded,
                                        color: Color.fromRGBO(252, 252, 252, 0.95),
                                        size: 36,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Text(
                                        "Users",
                                        style: TextStyle(
                                          color: Color.fromRGBO(252, 252, 252, 0.95),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: openSearch,
                                icon: Icon(
                                  Icons.search_rounded,
                                  color: Color.fromRGBO(252, 252, 252, 0.95),
                                  size: 32,
                                ),
                              )
                            ],
                          ),
                        ),
                        GridView.builder(
                          itemCount: visibleUsers.length,
                          shrinkWrap: true,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 25,
                            childAspectRatio: 1.5/1
                          ),
                          itemBuilder: (context, i) {
                            return FractionallySizedBox(
                              widthFactor: 1,
                              heightFactor: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(60, 60, 60, 1),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black45,
                                      blurRadius: 10,
                                      offset: Offset(0, 5)
                                    )
                                  ]
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 5),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${visibleUsers[i]["first_name"]} ${visibleUsers[i]["last_name"]}",
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(252, 252, 252, 0.95),
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600
                                                  ),
                                                ),
                                                Text(
                                                  visibleUsers[i]["username"],
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(252, 252, 252, 0.85),
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500
                                                  ),
                                                ),
                                                Text(
                                                  visibleUsers[i]["email"],
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(252, 252, 252, 0.7),
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w400
                                                  ),
                                                ),
                                                Text(
                                                  roles[visibleUsers[i]["role"]],
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(252, 252, 252, 0.85),
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w600
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            CircleAvatar(
                                              minRadius: 28,
                                            ),
                                            Expanded(
                                              child: FractionallySizedBox(
                                                widthFactor: 1,
                                                heightFactor: 1,
                                                child: Align(
                                                  alignment: Alignment.bottomRight,
                                                  child: IconButton(
                                                    onPressed: () { Navigator.pushNamed(context, '/edituser', arguments: EditUserArguments(userHash, role, profilePicture, visibleUsers[i]["pk"], visibleUsers[i]["username"], visibleUsers[i]["email"], visibleUsers[i]["first_name"], visibleUsers[i]["last_name"], visibleUsers[i]["role"])); },
                                                    // onPressed: () {},
                                                    icon: Icon(
                                                      Icons.edit_rounded,
                                                      color: Color.fromRGBO(107, 212, 37, 0.95),
                                                      size: 22,
                                                    )
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ),
                            );
                          }
                        )
                      ]
                    )
                  )
                ),
              )
            ]
          ),
        )
      ),
      bottomNavigationBar: generateNavigationBar(userHash, role, profilePicture, setState, getContext)
    );
  }
}