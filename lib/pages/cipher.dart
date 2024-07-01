import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:ventike/api/cipher.dart';
import 'package:ventike/api/events_data.dart';
import 'package:ventike/utils/args.dart';
import 'package:ventike/utils/vars.dart';

class CipherPage extends StatefulWidget {
  const CipherPage({super.key});

  @override
  State<CipherPage> createState() => _CipherPageState();
}

class _CipherPageState extends State<CipherPage> {
  String userHash = "";
  int role = 2;
  String? profilePicture;

  String apiKey = "";
  List<dynamic> partners = [];
  List<dynamic> events = [];

  List<Map<String, String>> messages = [{"role": "system", "content": 'You are a helpful assistant named Cipher. You work for a CTE company named Ventike. You respond to queries happily and kindly whilst being friendly and formal (speak in a business-like manner). You will only respond with the information given here. If you are asked about anything outside of this dataset, respectfully decline to respond.\n\nInformation:\nHow to add a partner? (Switch to the "Partners" tab, Press the "+" button in the top-right corner, Fill in all necessary information, Press the "Save" button)\nHow to modify a partner? (Switch to the "Partners" tab, Press the green "EDIT" button on the partner you would like to change, Modify any information necessary, Press the "Save" button)\nHow to add an event? (Switch to the "Events" tab, Press the "+" button in the top-right corner, Fill in all necessary information, Press the "Save" button)\nHow to modify an event? (Switch to the "Events" tab, Press the green pencil button on the event you would like to change, Modify any information necessary, Press the "Save" button)'}];

  TextEditingController inputController = TextEditingController();
  ScrollController scrollController = ScrollController();

  bool firstRun = true;

  Future<void> getAPIKey() async {
    Response res = await requestAPIKey(userHash);
    if (this.mounted) {
      if (res.statusCode == 200) {
        setState(() {
          print(res.body);
          final data = jsonDecode(res.body);
          apiKey = data["api_key"];
        });
      } else {
        // TBD - Something Went Wrong
      }
    }
  }

  Future<void> getAIData() async {
    Response res = await requestAIData(userHash);
    if (this.mounted) {
      if (res.statusCode == 200) {
        setState(() {
          print(res.body);
          final data = jsonDecode(res.body);
          apiKey = data[0]["api_key"];
          partners = data[1];
          events = data[2];

          messages[0]["content"] = "You are a helpful assistant named Cipher. You work for a company that makes CTE (Career and Technical Education) software named Ventike. You respond to queries happily and kindly whilst being friendly and formal (speak in a business-like manner). You have been given a list of FAQs and event/partner data. You will only respond with the information given here. If you are asked about anything outside of this dataset, respectfully decline to respond. You may list and reformat this data for the users' needs.\n\nFAQs:\nHow to add a partner? (Switch to the 'Partners' tab, Press the '+' button in the top-right corner, Fill in all necessary information, Press the 'Save' button)\nHow to modify a partner? (Switch to the 'Partners' tab, Press the green 'EDIT' button on the partner you would like to change, Modify any information necessary, Press the 'Save' button)\nHow to add an event? (Switch to the 'Events' tab, Press the '+' button in the top-right corner, Fill in all necessary information, Press the 'Save' button)\nHow to modify an event? (Switch to the 'Events' tab, Press the green pencil button on the event you would like to change, Modify any information necessary, Press the 'Save' button)\nWhat is a partner? (A partner is a group that works with your CTE department. You can store their information, contact details, type of organization, contact information of an individual working for the partner, tags related to them, and the resources they have\nWhat is an event? (An event is something that occurs at a point in time that pertains to your CTE department. You can store event details and the partners that will be there)\nWhat are the different partner types? (Business, Community, Education, Other)\nWhat are the different types of resources a partner can have? (Financial, Human, Physical, Other)\n\nPartners (Name, Description, Email, Phone Number, Type of Partner, (Individual First Name, Individual Last Name, Individual Email, Individual Phone Number), (Resources(Name, Type of Resource, Quantity)), (Tags)):";


          String partnersString = "";

          for (final partner in partners) {
            String resourcesString = "";
            for (final resource in partner["resources"]) {
              resourcesString = "$resourcesString, (${resource["name"]}, ${resourceTypes[resource["type"]]}, ${resource["amount"]})";
              // resourcesString = resourcesString + ", (" + resource["name"] + ", " + resourceTypes[resource["type"]] + ", " + resource["amount"] + ")";
            }

            if (resourcesString != "") {
              resourcesString = resourcesString.substring(2);
            }

            String tagsString = "";
            for (final tag in partner["tags"]) {
              tagsString = "$tagsString, ${tag["name"]}";
              // tagsString = tagsString + ", " + tag["name"];
            }

            if (tagsString != "") {
              tagsString = tagsString.substring(2);
            }

            partnersString = "$partnersString\n${partner["name"]}, ${partner["description"]}, ${partner["email"]}, ${partner["phone"]}, ${partnerTypes[partner["type"]]}, (${partner["individual"]["first_name"]}, ${partner["individual"]["last_name"]}, ${partner["individual"]["email"]}, ${partner["individual"]["phone"]}), ($resourcesString), ($tagsString)";
          }

          if (partnersString == "") {
            messages[0]["content"] = "${messages[0]["content"]}\nN/A";
          } else {
            messages[0]["content"] = "${messages[0]["content"]}$partnersString";
          }

          messages[0]["content"] = "${messages[0]["content"]}\n\nEvents (Name, Description, Date, Start Time, End Time, (Partners Involved)):";

          String eventsString = "";

          for (final event in events) {
            String partnersString = "";
            for (final partner in event["partners"]) {
              partnersString = "$partnersString, ${partner["name"]}";
              // partnersString = partnersString + ", " + partner["name"];
            }

            if (partnersString != "") {
              partnersString = partnersString.substring(2);
            }

            eventsString = "$eventsString\n${event["name"]}, ${event["description"]}, ${event["date"]}, ${event["start_time"]}, ${event["end_time"]}, ($partnersString)";
          }

          if (eventsString == "") {
            messages[0]["content"] = "${messages[0]["content"]}\nN/A";
          } else {
            messages[0]["content"] = "${messages[0]["content"]}$eventsString";
          }
        });
      } else {
        // TBD - Something Went Wrong
      }
    }
  }

  void send() {
    String input = inputController.text;
    
    if (input == "" || apiKey == "") {
      return;
    }

    setState(() {
      messages.add({"role": "user", "content": input});
      inputController.text = "";
      // scrollController.animateTo(
      //   scrollController.position.maxScrollExtent,
      //   duration: Duration(seconds: 1),
      //   curve: Curves.fastOutSlowIn
      // );
    });

    sendMessage(messages, apiKey).then((res) {
      if (this.mounted) {
        print(res.statusCode);
        print(res.body);

        final data = jsonDecode(res.body);

        if (res.statusCode == 200) {
          setState(() { 
            messages.add({"role": "assistant", "content": data["choices"][0]["message"]["content"]});
            inputController.text = "";
            // scrollController.animateTo(
            //   scrollController.position.maxScrollExtent,
            //   duration: Duration(seconds: 1),
            //   curve: Curves.fastOutSlowIn
            // );
          });
        }
      }
    });
  }

  // void scrollToBottom() {
  //   scrollController.animateTo(
  //     scrollController.position.maxScrollExtent,
  //     duration: Duration(seconds: 1),
  //     curve: Curves.fastOutSlowIn
  //   );
  // }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    inputController.dispose();
    super.dispose();
  }

  // @override
  // void initState() {
  //   WidgetsBinding.instance.addPostFrameCallback((duration) { scrollToBottom(); });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    if (firstRun) {
      final args = ModalRoute.of(context)!.settings.arguments as Arguments;
      userHash = args.userHash;
      role = args.role;
      profilePicture = args.profilePicture;

      // getImageString();

      // getAPIKey();
      getAIData();

      firstRun = false;
    }
    // message = args.message;
    // messageIcon = args.messageIcon;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 49, 49, 49),
        foregroundColor: const Color.fromRGBO(252, 252, 252, 0.95),
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/logo.png'),
                  backgroundColor: Color.fromRGBO(252, 252, 252, 0.12),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Cipher",
                  style: TextStyle(
                    color: Color.fromRGBO(252, 252, 252, 0.95),
                    fontSize: 28,
                    fontWeight: FontWeight.w700
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 56, 56, 56),
      body: Container(
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          reverse: true,
          controller: scrollController,
          child: FractionallySizedBox(
            widthFactor: 1,
            child: Column(
              children: () {
                List<Widget> res = [];
            
                for (int i = 1; i < messages.length; i++) {
                  if (messages[i]["role"] == "user") {
                    res.add(
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded( child: Container(), ),
                            Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(66, 66, 66, 1),
                                borderRadius: BorderRadius.circular(15)
                              ),
                              padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                              child: Text(
                                messages[i]["content"]!,
                                style: TextStyle(
                                  color: Color.fromRGBO(252, 252, 252, 0.95),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: CircleAvatar(),
                            )
                          ]
                        ),
                      )
                    );
                  } else {
                    res.add(
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: CircleAvatar(
                                  backgroundImage: AssetImage('assets/images/logo.png'),
                                  backgroundColor: Color.fromRGBO(252, 252, 252, 0.12),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 7,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(59, 64, 55, 1),
                                  borderRadius: BorderRadius.circular(15)
                                ),
                                padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                                child: Text(
                                  messages[i]["content"]!,
                                  style: TextStyle(
                                    color: Color.fromRGBO(107, 212, 37, 0.95),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(child: Container())
                          ]
                        ),
                      )
                    );
                  }
                }
            
                return res;
              }(),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(62, 62, 62, 1)
        ),
        height: 100,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                controller: inputController,
                onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                textAlignVertical: TextAlignVertical.center,
                cursorColor: const Color.fromRGBO(252, 252, 252, 0.3),
                cursorHeight: 28,
                cursorWidth: 4,
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
                  hintText: "Send a message...",
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(252, 252, 252, 0.3),
                  ),
                  border: InputBorder.none
                  // border: OutlineInputBorder(
                  //   borderRadius: BorderRadius.all(Radius.circular(8)),
                  //   borderSide: BorderSide(width: 0, style: BorderStyle.none)
                  // ),
                  // focusedBorder: OutlineInputBorder(
                  //   borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0.3)),
                  //   borderRadius: BorderRadius.all(Radius.circular(8))
                  // ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                onPressed: send,
                icon: Icon(
                  Icons.send_rounded,
                  color: Color.fromRGBO(252, 252, 252, 0.95),
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}