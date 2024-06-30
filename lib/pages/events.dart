import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ventike/api/events_data.dart';
import 'package:ventike/utils/args.dart';
import 'package:ventike/utils/dates.dart';
import 'package:ventike/utils/vars.dart';
import 'package:ventike/widgets/navbar.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  String userHash = "";
  int role = 2;
  String? profilePicture;

  List<dynamic> allEvents = [];
  List<dynamic> visibleEvents = [];
  int presentIndex = 0;
  String searchTerm = "";
  bool showUpcomingEvents = true;

  bool firstRun = true;

  BuildContext getContext() {
    return context;
  }

  void determinePresentIndex() {
    DateTime now = DateTime.now();
    String presentDate = "${now.year.toString()}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}";
    String presentTime = "${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}:${now.second.toString().padLeft(2,'0')}";

    for (int i = 0; i < visibleEvents.length; i++) {
      if (presentDate.compareTo(visibleEvents[i]["date"]) == 0) {
        if (presentTime.compareTo(visibleEvents[i]["start_time"]) >= 0) {
          presentIndex = i;
          return;
        }
      } else if (presentDate.compareTo(visibleEvents[i]["date"]) > 0) {
        presentIndex = i;
        return;
      }
    }

    presentIndex = visibleEvents.length;
  }

  Future<void> refreshEvents() async {
    Response res = await requestEvents(userHash);
    if (res.statusCode == 200) {
      setState(() {
        print(res.body);
        allEvents = jsonDecode(res.body) as List<dynamic>;
        allEvents.sort((event1, event2) {
          if (event2["date"] != event1["date"]) {
            return event2["date"].compareTo(event1["date"]);
          }
          if (event2["start_time"] != event1["start_time"]) {
            return event2["start_time"].compareTo(event1["start_time"]);
          }
          if (event2["end_time"] != event1["end_time"]) {
            return event2["end_time"].compareTo(event1["end_time"]);
          }
          return 0;
        });
        visibleEvents = allEvents;
        print(visibleEvents.toString());
        determinePresentIndex();
        print(presentIndex);
        searchTerm = "";
      });
    } else {
      // TBD - Something Went Wrong
    }
  }

  void search(String value) {
    searchTerm = value;
    setState(() {
      visibleEvents = [];
    });

    final terms = value.split(" ");
    List<String> cleanedTerms = [];

    for (String term in terms) {
      if (term.trim().isNotEmpty) {
        cleanedTerms.add(term.trim().toLowerCase());
      }
    }

    // print(cleanedTerms.toString());

      for (final event in allEvents) {
        bool canAdd = true;

        for (String term in cleanedTerms) {
          bool termExists = false;

          if (event["name"].toLowerCase().contains(term) || event["description"].toLowerCase().contains(term)) {
            termExists = true;
          } else {
            for (final partner in event["partners"]) {
              if (partner["name"].toLowerCase().contains(term)) {
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
        if (canAdd) {
          visibleEvents.add(event);
        }

        setState(() {
          determinePresentIndex();
        });
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
            cursorColor: Color.fromRGBO(252, 252, 252, 0.7),
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
      navbarIndex = 2;
    });

    if (firstRun) {
      refreshEvents();
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
                    "Events",
                    style: TextStyle(
                      color: Color.fromRGBO(252, 252, 252, 0.95),
                      fontSize: 48,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  IconButton(
                    onPressed: openSearch,
                    icon: Icon(
                      Icons.search_rounded,
                      color: Color.fromRGBO(252, 252, 252, 0.95),
                      size: 50,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(252, 252, 252, 0.02),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            TextButton(
                              onPressed: () { 
                                setState(() {
                                  showUpcomingEvents = true;                                
                                });
                              },
                              style: TextButton.styleFrom(
                                // minimumSize: Size.zero,
                                backgroundColor: Color.fromRGBO(56, 56, 56, showUpcomingEvents ? 1 : 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))
                                ),
                                padding: EdgeInsets.only(left: 20, right: 20),
                                // minimumSize: Size(50, 30),
                                // tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "Upcoming",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  height: 4
                                ),
                              )
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  showUpcomingEvents = false;                                
                                });
                              },
                              style: TextButton.styleFrom(
                                // minimumSize: Size.zero,
                                backgroundColor: Color.fromRGBO(56, 56, 56, showUpcomingEvents ? 0 : 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))
                                ),
                                padding: EdgeInsets.only(left: 20, right: 20),
                                // minimumSize: Size(50, 30),
                                // tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "Past",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  height: 4
                                ),
                              )
                            )
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            // color: Color.fromRGBO(252, 252, 252, 1)
                          ),
                          child: IconButton(
                            onPressed: () { Navigator.pushNamed(context, "/newevent", arguments: Arguments(userHash, role, profilePicture)); },
                            padding: EdgeInsets.all(10),
                            icon: const Icon(
                              Icons.add_rounded,
                              size: 42,
                              color: Color.fromRGBO(252, 252, 252, 0.95),
                            )
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(56, 56, 56, 1),
                          borderRadius: BorderRadius.only(topRight: Radius.circular(8), topLeft: Radius.circular(showUpcomingEvents ? 0 : 8), bottomRight: Radius.circular(8), bottomLeft: Radius.circular(8)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 10,
                              offset: Offset(0, 5)
                            )
                          ]
                        ),
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
                        child: RefreshIndicator(
                          onRefresh: refreshEvents,
                          child: () {
                            if ((showUpcomingEvents ? presentIndex : visibleEvents.length - presentIndex) > 0) {
                              return GridView.builder(
                                itemCount: showUpcomingEvents ? presentIndex : visibleEvents.length - presentIndex,
                                shrinkWrap: true,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isMobile ? 2 : 3,
                                  mainAxisSpacing: 15,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 1/0.9
                                ),
                                itemBuilder: (context, index) {
                                  final i = showUpcomingEvents ? presentIndex - index - 1 : presentIndex + index;

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(62, 62, 62, 1),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black45,
                                          blurRadius: 10,
                                          offset: Offset(0, 5)
                                        )
                                      ]
                                    ),
                                    padding: EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 0),
                                    child: FractionallySizedBox(
                                      widthFactor: 1,
                                      heightFactor: 1,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: FractionallySizedBox(
                                              widthFactor: 0.7,
                                              child: Column(
                                                children: [
                                                  FractionallySizedBox(
                                                    widthFactor: 1,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(bottom: 8),
                                                      child: Text(
                                                        visibleEvents[i]["name"],
                                                        // "F",
                                                        // textAlign: TextAlign.left,
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                          color: Color.fromRGBO(252, 252, 252, 0.95)
                                                        )
                                                      ),
                                                    ),
                                                  ),
                                                  FractionallySizedBox(
                                                    widthFactor: 1,
                                                    child: Text(
                                                      visibleEvents[i]["description"],
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 4,
                                                      style: TextStyle(
                                                        fontSize: 8,
                                                        fontWeight: FontWeight.w500,
                                                        color: Color.fromRGBO(252, 252, 252, 0.9)
                                                      )
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12),
                                                    color: Color.fromRGBO(252, 252, 252, 0.08)
                                                  ),
                                                  // padding: EdgeInsets.only(top: 5, left: 5),
                                                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                                                  child: Text(
                                                    parseDateWords(visibleEvents[i]["date"]),
                                                    style: TextStyle(
                                                      color: Color.fromRGBO(255, 255, 255, 1),
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w500
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () { Navigator.pushNamed(context, '/editevent', arguments: EditEventArguments(userHash, role, profilePicture, visibleEvents[i]["pk"], visibleEvents[i]["name"], visibleEvents[i]["description"], visibleEvents[i]["date"], visibleEvents[i]["start_time"], visibleEvents[i]["end_time"], visibleEvents[i]["partners"])); },
                                                iconSize: 24,
                                                style: IconButton.styleFrom(
                                                  padding: EdgeInsets.all(0)
                                                ),
                                                icon: Icon(
                                                  Icons.edit_rounded,
                                                  color: Color.fromRGBO(107, 212, 37, 1),
                                                )
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  );
                                }
                              );
                            }
                            return FractionallySizedBox(
                              widthFactor: 1,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  "No items currently",
                                  style: TextStyle(
                                    color: Colors.white
                                  ),
                                ),
                              ),
                            );
                          }()
                        ),
                      ),
                    )
                  ]
                )
              )
            )
          ]
        ),
      ),
      bottomNavigationBar: generateNavigationBar(userHash, role, profilePicture, setState, getContext)
    );
  }
}