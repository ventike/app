import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ventike/api/dashboard_data.dart';
import 'package:ventike/api/partners_data.dart';
import 'package:ventike/utils/args.dart';
import 'package:ventike/utils/vars.dart';
import 'package:ventike/widgets/navbar.dart';

class PartnersPage extends StatefulWidget {
  const PartnersPage({super.key});

  @override
  State<PartnersPage> createState() => _PartnersPageState();
}

class _PartnersPageState extends State<PartnersPage> {
  String userHash = "";
  int role = 2;
  String? profilePicture;

  List<dynamic> allPartners = [];
  List<dynamic> visiblePartners = [];
  String searchTerm = "";

  bool firstRun = true;

  BuildContext getContext() {
    return context;
  }

  Future<void> refreshPartners() async {
    Response res = await requestPartners(userHash);
    if (this.mounted) {
      if (res.statusCode == 200) {
        if (this.mounted) {
          setState(() {
            print(res.body);
            allPartners = jsonDecode(res.body) as List<dynamic>;
            visiblePartners = allPartners;
            searchTerm = "";
          });
        }
      } else {
        // TBD - Something Went Wrong
      }
    }
  }

  Future<void> exportPartners() async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'output.json',
    );

    if (outputFile != null) {
      List<dynamic> partnersData = [];

      for (final partner in visiblePartners) {
        partnersData.add({
          "name": partner["name"],
          "description": partner["description"],
          "email": partner["email"],
          "phone": partner["phone"],
          "type": partnerTypes[partner["type"]],
          "individual": {
            "first_name": partner["individual"]["first_name"],
            "last_name": partner["individual"]["last_name"],
            "email": partner["individual"]["email"],
            "phone": partner["individual"]["phone"],
          },
          "tags": () {
            List<String> res = [];

            for (final tag in partner["tags"]) {
              res.add(tag["name"]);
            }

            return res;
          }(),
          "resources": () {
            List<dynamic> res = [];

            for (final resource in partner["resources"]) {
              res.add({
                "name": resource["name"],
                "type": resourceTypes[resource["type"]],
                "amount": resource["amount"]
              });
            }

            return res;
          }(),
        });
      }

      String output = jsonEncode(partnersData);
      File file = File(outputFile);
      file.writeAsString(output);
    }
  }

  void search(String value) {
    searchTerm = value;
    setState(() {
      visiblePartners = [];
    });

    final terms = value.split(" ");
    List<String> cleanedTerms = [];

    for (String term in terms) {
      if (term.trim().isNotEmpty) {
        cleanedTerms.add(term.trim().toLowerCase());
      }
    }

    // print(cleanedTerms.toString());

    for (final partner in allPartners) {
      bool canAdd = true;

      for (String term in cleanedTerms) {
        if (term[0] == '#' && term.length > 1) {
          String tagTerm = term.substring(1);
          bool tagExists = false;
          for (final tag in partner["tags"]) {
            if (tag["name"].toLowerCase() == tagTerm) {
              tagExists = true;
              break;
            }
          }
          if (!tagExists) {
            canAdd = false;
            break;
          }
        } else {
          bool termExists = false;

          if (partner["name"].toLowerCase().contains(term) || partner["description"].toLowerCase().contains(term) || partner["email"].toLowerCase().contains(term) || partner["phone"].toLowerCase().contains(term) || partner["individual"]["first_name"].toLowerCase().contains(term) || partner["individual"]["last_name"].toLowerCase().contains(term) || partner["individual"]["email"].toLowerCase().contains(term) || partner["individual"]["phone"].toLowerCase().contains(term)) {
            termExists = true;
          } else {
            for (final resource in partner["resources"]) {
              if (resource["name"].toLowerCase().contains(term)) {
                termExists = true;
                break;
              }
            }
          }

          if (!termExists) {
            canAdd = false;
            break;
          }
        }
      }

      if (canAdd) {
        setState(() {
          visiblePartners.add(partner); 
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

  // @override
  // void initState() {
  //   super.initState();
  //   refreshPartners();
  //   // WidgetsBinding.instance.addPostFrameCallback((_) => refreshPartners());
  // }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Arguments;
    userHash = args.userHash;
    role = args.role;
    profilePicture = args.profilePicture;

    setState(() {
      navbarIndex = 1;
    });

    if (firstRun) {
      refreshPartners();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Partners",
                    style: TextStyle(
                      color: Color.fromRGBO(252, 252, 252, 0.95),
                      fontSize: 48,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  GestureDetector(
                    onLongPress: exportPartners,
                    child: IconButton(
                      onPressed: openSearch,
                      icon: Icon(
                        Icons.search_rounded,
                        color: Color.fromRGBO(252, 252, 252, 0.95),
                        size: 50,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(56, 56, 56, 1),
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
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () { Navigator.pushNamed(context, "/newpartner", arguments: Arguments(userHash, role, profilePicture)); },
                            icon: const Icon(
                              Icons.add_rounded,
                              size: 42,
                              color: Color.fromRGBO(252, 252, 252, 0.95),
                            )
                          ),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: RefreshIndicator(
                            color: const Color.fromRGBO(107, 212, 37, 0.95),
                            backgroundColor: const Color.fromRGBO(62, 62, 62, 1),
                            onRefresh: refreshPartners,
                            child: GridView.builder(
                              itemCount: visiblePartners.length,
                              // shrinkWrap: true,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isMobile ? 1 : 2,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 10,
                                childAspectRatio: 2.05/1
                              ),
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color.fromRGBO(62, 62, 62, 1),
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 10,
                                        // spreadRadius: 0.5,
                                        offset: Offset(0, 5),
                                        color: Colors.black45
                                      )
                                    ]
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: () {
                                        List<Widget> res = [
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(right: index % 2 == 0 ? 0 : 15, left: index % 2 == 0 ? 15 : 0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 0),
                                                    child: Text(
                                                      visiblePartners[index]["name"],
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                        color: Color.fromRGBO(252, 252, 252, 0.95),
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.w700
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 1, bottom: 10),
                                                    child: Text(
                                                      visiblePartners[index]["description"],
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                        color: Color.fromRGBO(252, 252, 252, 0.85),
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w500
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 10),
                                                    child: SingleChildScrollView(
                                                      scrollDirection: Axis.horizontal,
                                                      child: Row(
                                                        children: () {
                                                          List<Widget> res = [];
                                                      
                                                          for (var i = 0; i < visiblePartners[index]["tags"].length; i++) {
                                                            res.add(
                                                              Padding(
                                                                padding: EdgeInsets.only(right: i + 1 == visiblePartners[index]["tags"].length ? 0 : 10),
                                                                child: Container(
                                                                  alignment: Alignment.center,
                                                                  decoration: BoxDecoration(
                                                                    color: Color.fromRGBO(visiblePartners[index]["tags"][i]["color_red"], visiblePartners[index]["tags"][i]["color_green"], visiblePartners[index]["tags"][i]["color_blue"], 0.95),
                                                                    borderRadius: BorderRadius.circular(8)
                                                                  ),
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.only(right: 10, left: 10, top: 1, bottom: 1),
                                                                    child: Text(
                                                                      visiblePartners[index]["tags"][i]["name"],
                                                                      style: const TextStyle(
                                                                        color: Color.fromRGBO(255, 255, 255, 1),
                                                                        fontSize: 10,
                                                                        fontWeight: FontWeight.w400
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            );
                                                          }
                                                      
                                                          return res;
                                                        }()
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment: index % 2 == 0 ? Alignment.centerRight : Alignment.centerLeft,
                                                    // child: ColoredBox(color: Colors.red,),
                                                    child: SizedBox(
                                                      height: 27,
                                                      width: 70,
                                                      child: TextButton(
                                                        onPressed: () { Navigator.pushNamed(context, '/editpartner', arguments: EditPartnerArguments(userHash, role, profilePicture, visiblePartners[index]["pk"], visiblePartners[index]["name"], visiblePartners[index]["description"], visiblePartners[index]["type"], visiblePartners[index]["email"], visiblePartners[index]["phone"], visiblePartners[index]["image"], visiblePartners[index]["individual"]["first_name"], visiblePartners[index]["individual"]["last_name"], visiblePartners[index]["individual"]["email"], visiblePartners[index]["individual"]["phone"], visiblePartners[index]["tags"], visiblePartners[index]["resources"])); },
                                                        style: TextButton.styleFrom(
                                                          backgroundColor: const Color.fromRGBO(107, 212, 37, 0.05),
                                                          padding: const EdgeInsets.all(0),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                            // side: BorderSide(
                                                            //   color: Color.fromRGBO(107, 212, 37, 0.95)
                                                            // )
                                                          )
                                                        ),
                                                        child: const Padding(
                                                          padding: EdgeInsets.only(right: 5, left: 5),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                "Edit",
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Color.fromRGBO(107, 212, 37, 0.95),
                                                                  fontWeight: FontWeight.w300
                                                                ),
                                                              ),
                                                              Icon(
                                                                Icons.edit_rounded,
                                                                color: Color.fromRGBO(107, 212, 37, 0.95),
                                                                size: 24,
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: index % 2 == 0 ? 0 : 5, right: index % 2 == 0 ? 5 : 0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                color: const Color.fromRGBO(252, 252, 252, 0.08)
                                              ),
                                              clipBehavior: Clip.hardEdge,
                                              child: AspectRatio(
                                                aspectRatio: 1,
                                                // child: Image.asset(
                                                //   'assets/images/questionmark.png',
                                                //   fit: BoxFit.cover,
                                                // ),
                                                child: Image.memory(
                                                  base64.decode(visiblePartners[index]["image"] ?? placeholderPartnerImage),
                                                  fit: BoxFit.cover
                                                ),
                                              )
                                            ),
                                          )
                                        ];
              
                                        if (index % 2 == 0) {
                                          res = res.reversed.toList();
                                        }
              
                                        return res;
                                      }()
                                    ),
                                  )
                                );
                              }
                            ),
                          ),
                        ),
                      )
                    ]
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