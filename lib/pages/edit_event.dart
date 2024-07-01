import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ventike/api/events_data.dart';
import 'package:ventike/api/partners_data.dart';
import 'package:ventike/utils/args.dart';
import 'package:ventike/utils/dates.dart';
import 'package:ventike/widgets/navbar.dart';

class EditEventPage extends StatefulWidget {
  const EditEventPage({super.key});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  String userHash = "";
  int role = 2;
  String? profilePicture;

  int id = -1;
  String name = "";
  String description = "";
  String date = "";
  String startTime = "";
  String endTime = "";
  List<dynamic> partners = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<dynamic> allPartners = [];

  bool firstRun = true;
  bool panelOpen = false;

  String errorMessage = "";
  double errorMessagePadding = 0;
  bool saveButtonEnabled = true;
  bool deleteButtonEnabled = true;

  DateTime? dateObject;
  TimeOfDay? startTimeObject;
  TimeOfDay? endTimeObject;

  ScrollController scrollController = ScrollController();

  List<bool> partnersSelected = [];
  List<int> selectedIds = [];

  BuildContext getContext() {
    return context;
  }

  void save() {
    String name = nameController.text;
    String description = descriptionController.text;

    setState(() {
      errorMessage = "";
      errorMessagePadding = 0;
      saveButtonEnabled = false;
    });

    if (name == "" || description == "" || dateObject == null || startTimeObject == null || endTimeObject == null) {
      setState(() {
        errorMessage = "Please fill all fields";
        errorMessagePadding = 15;
        scrollController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
        saveButtonEnabled = true;
      });
      return;
    }

    String dateString = "${dateObject?.year.toString()}-${dateObject?.month.toString().padLeft(2,'0')}-${dateObject?.day.toString().padLeft(2,'0')}";
    String startTimeString = "${startTimeObject?.hour.toString().padLeft(2,'0')}:${startTimeObject?.minute.toString().padLeft(2,'0')}";
    String endTimeString = "${endTimeObject?.hour.toString().padLeft(2,'0')}:${endTimeObject?.minute.toString().padLeft(2,'0')}";

    if (startTimeString.compareTo(endTimeString) > 0) {
      setState(() {
        errorMessage = "Event Must End After It Has Begun";
        errorMessagePadding = 15;
        scrollController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
        saveButtonEnabled = true;
      });
      return;
    }

    List<int> selectedPartners = [];

    for (int i = 0; i < partnersSelected.length; i++) {
      if (partnersSelected[i]) {
        selectedPartners.add(allPartners[i]["pk"]);
      }
    }

    modifyEvent(userHash, id, name, description, dateString, startTimeString, endTimeString, selectedPartners).then((res) {
      if (this.mounted) {
        print(res.statusCode);
        print(res.body);

        if (res.statusCode == 200) {
          Navigator.of(context).popAndPushNamed('/events', arguments: Arguments(userHash, role, profilePicture));
        } else if (res.statusCode == 409) {
          setState(() {
            errorMessage = "Invalid Date/Time(s)";
            errorMessagePadding = 15;
            scrollController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
            saveButtonEnabled = true;
          });
          return;
        } else if (res.statusCode == 412) {
          setState(() {
            errorMessage = "Invalid Date/Time(s)";
            errorMessagePadding = 15;
            scrollController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
            saveButtonEnabled = true;
          });
          return;
        }

        setState(() {
          errorMessage = "Something Went Wrong";
          errorMessagePadding = 15;
          scrollController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
          saveButtonEnabled = true;
        });
      }
    });
  }

  void delete() {
    setState(() {
      errorMessage = "";
      errorMessagePadding = 0;
      deleteButtonEnabled = false;
    });

    deleteEvent(userHash, id).then((res) {
      if (this.mounted) {
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
      }
    });
  }

  void getAllPartners() async {
    Response res = await requestPartners(userHash);
    if (this.mounted) {
      if (res.statusCode == 200) {
        setState(() {
          print(res.body);
          allPartners = jsonDecode(res.body) as List<dynamic>;
          partnersSelected = [];

          for (final partner in allPartners) {
            partnersSelected.add(selectedIds.contains(partner["pk"]));
          }
        });
      } else {
        // TBD - Something Went Wrong
      }
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (firstRun) {
      final args = ModalRoute.of(context)!.settings.arguments as EditEventArguments;

      userHash = args.userHash;

      getAllPartners();


      role = args.role;
      profilePicture = args.profilePicture;

      // getImageString();

      id = args.id;
      name = args.name;
      description = args.description;
      date = args.date;
      startTime = args.startTime;
      endTime = args.endTime;
      partners = args.partners;

      dateObject = DateTime.tryParse(date);
      startTimeObject = TimeOfDay(hour: int.parse(startTime.split(":")[0]), minute: int.parse(startTime.split(":")[1]));
      endTimeObject = TimeOfDay(hour: int.parse(endTime.split(":")[0]), minute: int.parse(endTime.split(":")[1]));

      // log(base64.decode(image).toString());
      // print(args.image == null);

      for (final partner in partners) {
        selectedIds.add(partner["pk"]);
      }

      nameController.text = args.name;
      descriptionController.text = args.description;

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
                    "Edit Event",
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
                                      "Name:",
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
                                              controller: nameController,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Text(
                                      "Description:",
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
                                          height: 60,
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
                                              controller: descriptionController,
                                              onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                                              textAlignVertical: TextAlignVertical.center,
                                              cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                                              cursorHeight: 20,
                                              minLines: 2,
                                              maxLines: 2,
                                              style: const TextStyle(
                                                color: Color.fromRGBO(252, 252, 252, 0.7),
                                                // height: 2.25,
                                                // height: 1.3,
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
                                  TextButton(
                                    onPressed: () { showDatePicker(context: context, initialDate: dateObject, firstDate: DateTime(2000, 01, 01), lastDate: DateTime(2100, 01, 01)).then((obj) { dateObject = obj ?? dateObject; }); },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Color.fromRGBO(252, 252, 252, 0.08),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 25)
                                    ),
                                    child: Text(
                                      "Date",
                                      style: TextStyle(
                                        color: Color.fromRGBO(252, 252, 252, 0.95)
                                      ),
                                    )
                                  ),
                                  TextButton(
                                    onPressed: () { showTimePicker(context: context, initialTime: startTimeObject ?? TimeOfDay(hour: 0, minute: 0)).then((obj) { startTimeObject = obj ?? startTimeObject; }); },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Color.fromRGBO(252, 252, 252, 0.08),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15)
                                    ),
                                    child: Text(
                                      "Start Time",
                                      style: TextStyle(
                                        color: Color.fromRGBO(252, 252, 252, 0.95)
                                      ),
                                    )
                                  ),
                                  TextButton(
                                    onPressed: () { showTimePicker(context: context, initialTime: endTimeObject ?? TimeOfDay(hour: 0, minute: 0)).then((obj) { endTimeObject = obj ?? endTimeObject; }); },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Color.fromRGBO(252, 252, 252, 0.08),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15)
                                    ),
                                    child: Text(
                                      "End Time",
                                      style: TextStyle(
                                        color: Color.fromRGBO(252, 252, 252, 0.95)
                                      ),
                                    )
                                  ),
                                ],
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.only(bottom: 15),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       Flexible(
                            //         flex: 1,
                            //         child: Text(
                            //           "Phone:",
                            //           style: TextStyle(
                            //             color: Color.fromRGBO(252, 252, 252, 0.95),
                            //             fontSize: 18,
                            //             fontWeight: FontWeight.w700
                            //           ),
                            //         )
                            //       ),
                            //       Theme(
                            //         data: ThemeData(
                            //           textSelectionTheme: const TextSelectionThemeData(
                            //             selectionColor: Color.fromRGBO(252, 252, 252, 0.12),
                            //             selectionHandleColor: Color.fromRGBO(252, 252, 252, 0.95)
                            //           ),
                            //           cupertinoOverrideTheme: const CupertinoThemeData(
                            //             primaryColor: Color.fromRGBO(252, 252, 252, 0.95)
                            //           )
                            //         ),
                            //         child: Flexible(
                            //           flex: 2,
                            //           child: Padding(
                            //             padding: const EdgeInsets.only(left: 10),
                            //             child: SizedBox(
                            //               height: 40,
                            //               child: Container(
                            //                 decoration: BoxDecoration(
                            //                   boxShadow: [
                            //                     BoxShadow(
                            //                       blurRadius: 10,
                            //                       offset: Offset(0, 5),
                            //                       color: Colors.black45
                            //                     )
                            //                   ]
                            //                 ),
                            //                 child: TextField(
                            //                   // controller: phoneController,
                            //                   onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                            //                   textAlignVertical: TextAlignVertical.center,
                            //                   cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                            //                   cursorHeight: 20,
                            //                   style: const TextStyle(
                            //                     color: Color.fromRGBO(252, 252, 252, 0.7),
                            //                     height: 2.25,
                            //                     fontWeight: FontWeight.w700,
                            //                     fontSize: 18,
                            //                   ),
                            //                   decoration: const InputDecoration(
                            //                     contentPadding: EdgeInsets.only(left: 20),
                            //                     isDense: true,
                            //                     filled: true,
                            //                     fillColor: Color.fromRGBO(62, 62, 62, 1),
                            //                     // hintText: "Username",
                            //                     // hintStyle: TextStyle(
                            //                     //   color: Color.fromRGBO(39, 39, 39, 0.75),
                            //                     // ),
                            //                     border: OutlineInputBorder(
                            //                       borderRadius: BorderRadius.all(Radius.circular(8)),
                            //                       borderSide: BorderSide(width: 0, style: BorderStyle.none)
                            //                     ),
                            //                     focusedBorder: OutlineInputBorder(
                            //                       borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0.3)),
                            //                       borderRadius: BorderRadius.all(Radius.circular(8))
                            //                     ),
                            //                   ),
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //         ),
                            //       )
                            //     ],
                            //   ),
                            // ),
                            // Padding(
                            //   padding: const EdgeInsets.only(bottom: 15),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       Flexible(
                            //         flex: 1,
                            //         child: Text(
                            //           "Type:",
                            //           style: TextStyle(
                            //             color: Color.fromRGBO(252, 252, 252, 0.95),
                            //             fontSize: 18,
                            //             fontWeight: FontWeight.w700
                            //           ),
                            //         )
                            //       ),
                            //       // Flexible(
                            //       //   flex: 2,
                            //       //   child: Padding(
                            //       //     padding: const EdgeInsets.only(left: 10),
                            //       //     child: SizedBox(
                            //       //       height: 50,
                            //       //       child: Container(
                            //       //         decoration: BoxDecoration(
                            //       //           // boxShadow: [
                            //       //           //   BoxShadow(
                            //       //           //     blurRadius: 10,
                            //       //           //     offset: Offset(0, 5),
                            //       //           //     color: Colors.black45
                            //       //           //   )
                            //       //           // ]
                            //       //         ),
                            //       //         child: SegmentedButton(
                            //       //           segments: [
                            //       //             ButtonSegment<int>(
                            //       //               value: 0,
                            //       //               icon: Icon(
                            //       //                 Icons.business_rounded,
                            //       //                 size: 20,
                            //       //               ),
                            //       //               // label: Text("Business")
                            //       //             ),
                            //       //             ButtonSegment<int>(
                            //       //               value: 1,
                            //       //               icon: Icon(
                            //       //                 Icons.diversity_3_rounded,
                            //       //                 size: 20,
                            //       //               ),
                            //       //               // label: Text("Community")
                            //       //             ),
                            //       //             ButtonSegment<int>(
                            //       //               value: 2,
                            //       //               icon: Icon(
                            //       //                 Icons.school_rounded,
                            //       //                 size: 20,
                            //       //               ),
                            //       //               // label: Text("Community")
                            //       //             ),
                            //       //             ButtonSegment<int>(
                            //       //               value: 3,
                            //       //               icon: Icon(
                            //       //                 Icons.pending_rounded,
                            //       //                 size: 20,
                            //       //               ),
                            //       //               // label: Text("Community")
                            //       //             )
                            //       //           ],
                            //       //           // selected: partnerType,
                            //       //           // onSelectionChanged: updateType,
                            //       //           showSelectedIcon: false,
                            //       //           style: SegmentedButton.styleFrom(
                            //       //             foregroundColor: Color.fromRGBO(252, 252, 252, 0.7),
                            //       //             backgroundColor: Color.fromRGBO(252, 252, 252, 0.08),
                            //       //             selectedForegroundColor: Color.fromRGBO(252, 252, 252, 0.95),
                            //       //             selectedBackgroundColor: Color.fromRGBO(252, 252, 252, 0.2),
                            //       //             fixedSize: Size.fromHeight(50),
                            //       //             padding: EdgeInsets.all(0)
                            //       //           ),
                            //       //         ),
                            //       //       ),
                            //       //     ),
                            //       //   ),
                            //       // )
                            //     ],
                            //   ),
                            // ),
                            Divider(
                              color: Color.fromRGBO(252, 252, 252, 0.5),
                            ),
                            FractionallySizedBox(
                              widthFactor: 1,
                              child: ExpansionPanelList(
                                expansionCallback: (i, isOpen) {
                                  setState(() {
                                    panelOpen = isOpen;
                                  });
                                },
                                dividerColor: Color.fromRGBO(252, 252, 252, 0.5),
                                elevation: 0,
                                expandIconColor: Color.fromRGBO(252, 252, 252, 0.5),
                                children: [
                                  ExpansionPanel(
                                    headerBuilder: (context, isOpen) {
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Partners",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Color.fromRGBO(252, 252, 252, 0.7)
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    body: Column(
                                      children: () {
                                        List<Widget> res = [];

                                        for (int i = 0; i < partnersSelected.length; i++) {
                                          res.add(Container(
                                            decoration: BoxDecoration(
                                              color: Color.fromRGBO(252, 252, 252, 0.02)
                                            ),
                                            child: Theme(
                                              data: ThemeData(
                                                checkboxTheme: CheckboxThemeData(
                                                  side: BorderSide(
                                                    color: Color.fromRGBO(252, 252, 252, 0.5)
                                                  )
                                                )
                                              ),
                                              child: CheckboxListTile(
                                                value: partnersSelected[i],
                                                onChanged: (val) { setState(() {partnersSelected[i] = val ?? partnersSelected[i];}); },
                                                title: Text(
                                                  allPartners[i]["name"],
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(252, 252, 252, 0.95)
                                                  ),
                                                ),
                                                activeColor: Color.fromRGBO(107, 212, 37, 0.95),
                                                // overlayColor: WidgetStatePropertyAll(Color.fromRGBO(252, 252, 252, 0.95)),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  side: BorderSide(
                                                    color: Color.fromRGBO(252, 252, 252, 0.5)
                                                  )
                                                ),
                                                // checkboxShape: RoundedRectangleBorder(
                                                //   borderRadius: BorderRadius.circular(2),
                                                //   side: BorderSide(
                                                //     color: Color.fromRGBO(252, 252, 252, 0.95),
                                                //     width: 1
                                                //   )
                                                // ),
                                              ),
                                            ),
                                          ));
                                        }

                                        res.add(Divider(
                                          color: Color.fromRGBO(252, 252, 252, 0.5),
                                        ));
                                        return res;
                                      }()
                                    ),
                                    isExpanded: panelOpen,
                                    backgroundColor: Color.fromRGBO(252, 252, 252, 0.00),
                                  ),
                                  // ExpansionPanel(
                                  //   headerBuilder: (context, isOpen) {
                                  //     return Padding(
                                  //       padding: const EdgeInsets.only(left: 5),
                                  //       child: Align(
                                  //         alignment: Alignment.centerLeft,
                                  //         child: Text(
                                  //           "Individual",
                                  //           style: TextStyle(
                                  //             fontSize: 16,
                                  //             fontWeight: FontWeight.w700,
                                  //             color: Color.fromRGBO(252, 252, 252, 0.7)
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     );
                                  //   },
                                  //   body: Column(
                                  //     children: [
                                  //       Padding(
                                  //         padding: const EdgeInsets.only(bottom: 15),
                                  //         child: Row(
                                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //           children: [
                                  //             Flexible(
                                  //               flex: 1,
                                  //               child: Text(
                                  //                 "First Name:",
                                  //                 style: TextStyle(
                                  //                   color: Color.fromRGBO(252, 252, 252, 0.95),
                                  //                   fontSize: 18,
                                  //                   fontWeight: FontWeight.w700
                                  //                 ),
                                  //               )
                                  //             ),
                                  //             Theme(
                                  //               data: ThemeData(
                                  //                 textSelectionTheme: const TextSelectionThemeData(
                                  //                   selectionColor: Color.fromRGBO(252, 252, 252, 0.12),
                                  //                   selectionHandleColor: Color.fromRGBO(252, 252, 252, 0.95)
                                  //                 ),
                                  //                 cupertinoOverrideTheme: const CupertinoThemeData(
                                  //                   primaryColor: Color.fromRGBO(252, 252, 252, 0.95)
                                  //                 )
                                  //               ),
                                  //               child: Flexible(
                                  //                 flex: 2,
                                  //                 child: Padding(
                                  //                   padding: const EdgeInsets.only(left: 10),
                                  //                   child: SizedBox(
                                  //                     height: 40,
                                  //                     child: Container(
                                  //                       decoration: BoxDecoration(
                                  //                         boxShadow: [
                                  //                           BoxShadow(
                                  //                             blurRadius: 10,
                                  //                             offset: Offset(0, 5),
                                  //                             color: Colors.black45
                                  //                           )
                                  //                         ]
                                  //                       ),
                                  //                       child: TextField(
                                  //                         // controller: individualFirstNameController,
                                  //                         onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                                  //                         textAlignVertical: TextAlignVertical.center,
                                  //                         cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                                  //                         cursorHeight: 20,
                                  //                         style: const TextStyle(
                                  //                           color: Color.fromRGBO(252, 252, 252, 0.7),
                                  //                           height: 2.25,
                                  //                           fontWeight: FontWeight.w700,
                                  //                           fontSize: 18,
                                  //                         ),
                                  //                         decoration: const InputDecoration(
                                  //                           contentPadding: EdgeInsets.only(left: 20),
                                  //                           isDense: true,
                                  //                           filled: true,
                                  //                           fillColor: Color.fromRGBO(62, 62, 62, 1),
                                  //                           // hintText: "Username",
                                  //                           // hintStyle: TextStyle(
                                  //                           //   color: Color.fromRGBO(39, 39, 39, 0.75),
                                  //                           // ),
                                  //                           border: OutlineInputBorder(
                                  //                             borderRadius: BorderRadius.all(Radius.circular(8)),
                                  //                             borderSide: BorderSide(width: 0, style: BorderStyle.none)
                                  //                           ),
                                  //                           focusedBorder: OutlineInputBorder(
                                  //                             borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0.3)),
                                  //                             borderRadius: BorderRadius.all(Radius.circular(8))
                                  //                           ),
                                  //                         ),
                                  //                       ),
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //             )
                                  //           ],
                                  //         ),
                                  //       ),
                                  //       Padding(
                                  //         padding: const EdgeInsets.only(bottom: 15),
                                  //         child: Row(
                                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //           children: [
                                  //             Flexible(
                                  //               flex: 1,
                                  //               child: Text(
                                  //                 "Last Name:",
                                  //                 style: TextStyle(
                                  //                   color: Color.fromRGBO(252, 252, 252, 0.95),
                                  //                   fontSize: 18,
                                  //                   fontWeight: FontWeight.w700
                                  //                 ),
                                  //               )
                                  //             ),
                                  //             Theme(
                                  //               data: ThemeData(
                                  //                 textSelectionTheme: const TextSelectionThemeData(
                                  //                   selectionColor: Color.fromRGBO(252, 252, 252, 0.12),
                                  //                   selectionHandleColor: Color.fromRGBO(252, 252, 252, 0.95)
                                  //                 ),
                                  //                 cupertinoOverrideTheme: const CupertinoThemeData(
                                  //                   primaryColor: Color.fromRGBO(252, 252, 252, 0.95)
                                  //                 )
                                  //               ),
                                  //               child: Flexible(
                                  //                 flex: 2,
                                  //                 child: Padding(
                                  //                   padding: const EdgeInsets.only(left: 10),
                                  //                   child: SizedBox(
                                  //                     height: 40,
                                  //                     child: Container(
                                  //                       decoration: BoxDecoration(
                                  //                         boxShadow: [
                                  //                           BoxShadow(
                                  //                             blurRadius: 10,
                                  //                             offset: Offset(0, 5),
                                  //                             color: Colors.black45
                                  //                           )
                                  //                         ]
                                  //                       ),
                                  //                       child: TextField(
                                  //                         // controller: individualLastNameController,
                                  //                         onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                                  //                         textAlignVertical: TextAlignVertical.center,
                                  //                         cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                                  //                         cursorHeight: 20,
                                  //                         style: const TextStyle(
                                  //                           color: Color.fromRGBO(252, 252, 252, 0.7),
                                  //                           height: 2.25,
                                  //                           fontWeight: FontWeight.w700,
                                  //                           fontSize: 18,
                                  //                         ),
                                  //                         decoration: const InputDecoration(
                                  //                           contentPadding: EdgeInsets.only(left: 20),
                                  //                           isDense: true,
                                  //                           filled: true,
                                  //                           fillColor: Color.fromRGBO(62, 62, 62, 1),
                                  //                           // hintText: "Username",
                                  //                           // hintStyle: TextStyle(
                                  //                           //   color: Color.fromRGBO(39, 39, 39, 0.75),
                                  //                           // ),
                                  //                           border: OutlineInputBorder(
                                  //                             borderRadius: BorderRadius.all(Radius.circular(8)),
                                  //                             borderSide: BorderSide(width: 0, style: BorderStyle.none)
                                  //                           ),
                                  //                           focusedBorder: OutlineInputBorder(
                                  //                             borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0.3)),
                                  //                             borderRadius: BorderRadius.all(Radius.circular(8))
                                  //                           ),
                                  //                         ),
                                  //                       ),
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //             )
                                  //           ],
                                  //         ),
                                  //       ),
                                  //       Padding(
                                  //         padding: const EdgeInsets.only(bottom: 15),
                                  //         child: Row(
                                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //           children: [
                                  //             Flexible(
                                  //               flex: 1,
                                  //               child: Text(
                                  //                 "Email:",
                                  //                 style: TextStyle(
                                  //                   color: Color.fromRGBO(252, 252, 252, 0.95),
                                  //                   fontSize: 18,
                                  //                   fontWeight: FontWeight.w700
                                  //                 ),
                                  //               )
                                  //             ),
                                  //             Theme(
                                  //               data: ThemeData(
                                  //                 textSelectionTheme: const TextSelectionThemeData(
                                  //                   selectionColor: Color.fromRGBO(252, 252, 252, 0.12),
                                  //                   selectionHandleColor: Color.fromRGBO(252, 252, 252, 0.95)
                                  //                 ),
                                  //                 cupertinoOverrideTheme: const CupertinoThemeData(
                                  //                   primaryColor: Color.fromRGBO(252, 252, 252, 0.95)
                                  //                 )
                                  //               ),
                                  //               child: Flexible(
                                  //                 flex: 2,
                                  //                 child: Padding(
                                  //                   padding: const EdgeInsets.only(left: 10),
                                  //                   child: SizedBox(
                                  //                     height: 40,
                                  //                     child: Container(
                                  //                       decoration: BoxDecoration(
                                  //                         boxShadow: [
                                  //                           BoxShadow(
                                  //                             blurRadius: 10,
                                  //                             offset: Offset(0, 5),
                                  //                             color: Colors.black45
                                  //                           )
                                  //                         ]
                                  //                       ),
                                  //                       child: TextField(
                                  //                         // controller: individualEmailController,
                                  //                         onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                                  //                         textAlignVertical: TextAlignVertical.center,
                                  //                         cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                                  //                         cursorHeight: 20,
                                  //                         style: const TextStyle(
                                  //                           color: Color.fromRGBO(252, 252, 252, 0.7),
                                  //                           height: 2.25,
                                  //                           fontWeight: FontWeight.w700,
                                  //                           fontSize: 18,
                                  //                         ),
                                  //                         decoration: const InputDecoration(
                                  //                           contentPadding: EdgeInsets.only(left: 20),
                                  //                           isDense: true,
                                  //                           filled: true,
                                  //                           fillColor: Color.fromRGBO(62, 62, 62, 1),
                                  //                           // hintText: "Username",
                                  //                           // hintStyle: TextStyle(
                                  //                           //   color: Color.fromRGBO(39, 39, 39, 0.75),
                                  //                           // ),
                                  //                           border: OutlineInputBorder(
                                  //                             borderRadius: BorderRadius.all(Radius.circular(8)),
                                  //                             borderSide: BorderSide(width: 0, style: BorderStyle.none)
                                  //                           ),
                                  //                           focusedBorder: OutlineInputBorder(
                                  //                             borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0.3)),
                                  //                             borderRadius: BorderRadius.all(Radius.circular(8))
                                  //                           ),
                                  //                         ),
                                  //                       ),
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //             )
                                  //           ],
                                  //         ),
                                  //       ),
                                  //       Padding(
                                  //         padding: const EdgeInsets.only(bottom: 15),
                                  //         child: Row(
                                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //           children: [
                                  //             Flexible(
                                  //               flex: 1,
                                  //               child: Text(
                                  //                 "Phone:",
                                  //                 style: TextStyle(
                                  //                   color: Color.fromRGBO(252, 252, 252, 0.95),
                                  //                   fontSize: 18,
                                  //                   fontWeight: FontWeight.w700
                                  //                 ),
                                  //               )
                                  //             ),
                                  //             Theme(
                                  //               data: ThemeData(
                                  //                 textSelectionTheme: const TextSelectionThemeData(
                                  //                   selectionColor: Color.fromRGBO(252, 252, 252, 0.12),
                                  //                   selectionHandleColor: Color.fromRGBO(252, 252, 252, 0.95)
                                  //                 ),
                                  //                 cupertinoOverrideTheme: const CupertinoThemeData(
                                  //                   primaryColor: Color.fromRGBO(252, 252, 252, 0.95)
                                  //                 )
                                  //               ),
                                  //               child: Flexible(
                                  //                 flex: 2,
                                  //                 child: Padding(
                                  //                   padding: const EdgeInsets.only(left: 10),
                                  //                   child: SizedBox(
                                  //                     height: 40,
                                  //                     child: Container(
                                  //                       decoration: BoxDecoration(
                                  //                         boxShadow: [
                                  //                           BoxShadow(
                                  //                             blurRadius: 10,
                                  //                             offset: Offset(0, 5),
                                  //                             color: Colors.black45
                                  //                           )
                                  //                         ]
                                  //                       ),
                                  //                       child: TextField(
                                  //                         // controller: individualPhoneController,
                                  //                         onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                                  //                         textAlignVertical: TextAlignVertical.center,
                                  //                         cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                                  //                         cursorHeight: 20,
                                  //                         style: const TextStyle(
                                  //                           color: Color.fromRGBO(252, 252, 252, 0.7),
                                  //                           height: 2.25,
                                  //                           fontWeight: FontWeight.w700,
                                  //                           fontSize: 18,
                                  //                         ),
                                  //                         decoration: const InputDecoration(
                                  //                           contentPadding: EdgeInsets.only(left: 20),
                                  //                           isDense: true,
                                  //                           filled: true,
                                  //                           fillColor: Color.fromRGBO(62, 62, 62, 1),
                                  //                           // hintText: "Username",
                                  //                           // hintStyle: TextStyle(
                                  //                           //   color: Color.fromRGBO(39, 39, 39, 0.75),
                                  //                           // ),
                                  //                           border: OutlineInputBorder(
                                  //                             borderRadius: BorderRadius.all(Radius.circular(8)),
                                  //                             borderSide: BorderSide(width: 0, style: BorderStyle.none)
                                  //                           ),
                                  //                           focusedBorder: OutlineInputBorder(
                                  //                             borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0.3)),
                                  //                             borderRadius: BorderRadius.all(Radius.circular(8))
                                  //                           ),
                                  //                         ),
                                  //                       ),
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //             )
                                  //           ],
                                  //         ),
                                  //       ),
                                  //       Divider(
                                  //         color: Color.fromRGBO(252, 252, 252, 0.5),
                                  //       )
                                  //     ],
                                  //   ),
                                  //   isExpanded: openPanels[1],
                                  //   backgroundColor: Color.fromRGBO(252, 252, 252, 0.00),
                                  // ),
                                  // ExpansionPanel(
                                  //   headerBuilder: (context, isOpen) {
                                  //     return Padding(
                                  //       padding: const EdgeInsets.only(left: 5),
                                  //       child: Align(
                                  //         alignment: Alignment.centerLeft,
                                  //         child: Text(
                                  //           "Tags",
                                  //           style: TextStyle(
                                  //             fontSize: 16,
                                  //             fontWeight: FontWeight.w700,
                                  //             color: Color.fromRGBO(252, 252, 252, 0.7)
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     );
                                  //   },
                                  //   body: Column(
                                  //     children: [
                                  //       Padding(
                                  //         padding: const EdgeInsets.only(bottom: 15),
                                  //         child: Row(
                                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //           children: [
                                  //             Flexible(
                                  //               flex: 1,
                                  //               child: Text(
                                  //                 "Values:",
                                  //                 style: TextStyle(
                                  //                   color: Color.fromRGBO(252, 252, 252, 0.95),
                                  //                   fontSize: 18,
                                  //                   fontWeight: FontWeight.w700
                                  //                 ),
                                  //               )
                                  //             ),
                                  //             Theme(
                                  //               data: ThemeData(
                                  //                 textSelectionTheme: const TextSelectionThemeData(
                                  //                   selectionColor: Color.fromRGBO(252, 252, 252, 0.12),
                                  //                   selectionHandleColor: Color.fromRGBO(252, 252, 252, 0.95)
                                  //                 ),
                                  //                 cupertinoOverrideTheme: const CupertinoThemeData(
                                  //                   primaryColor: Color.fromRGBO(252, 252, 252, 0.95)
                                  //                 )
                                  //               ),
                                  //               child: Flexible(
                                  //                 flex: 2,
                                  //                 child: Padding(
                                  //                   padding: const EdgeInsets.only(left: 10),
                                  //                   child: SizedBox(
                                  //                     height: 40,
                                  //                     child: Container(
                                  //                       decoration: BoxDecoration(
                                  //                         boxShadow: [
                                  //                           BoxShadow(
                                  //                             blurRadius: 10,
                                  //                             offset: Offset(0, 5),
                                  //                             color: Colors.black45
                                  //                           )
                                  //                         ]
                                  //                       ),
                                  //                       child: TextField(
                                  //                         // controller: tagsContoller,
                                  //                         onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                                  //                         textAlignVertical: TextAlignVertical.center,
                                  //                         cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                                  //                         cursorHeight: 20,
                                  //                         style: const TextStyle(
                                  //                           color: Color.fromRGBO(252, 252, 252, 0.7),
                                  //                           height: 2.25,
                                  //                           fontWeight: FontWeight.w700,
                                  //                           fontSize: 18,
                                  //                         ),
                                  //                         decoration: const InputDecoration(
                                  //                           contentPadding: EdgeInsets.only(left: 20),
                                  //                           isDense: true,
                                  //                           filled: true,
                                  //                           fillColor: Color.fromRGBO(62, 62, 62, 1),
                                  //                           // hintText: "Username",
                                  //                           // hintStyle: TextStyle(
                                  //                           //   color: Color.fromRGBO(39, 39, 39, 0.75),
                                  //                           // ),
                                  //                           border: OutlineInputBorder(
                                  //                             borderRadius: BorderRadius.all(Radius.circular(8)),
                                  //                             borderSide: BorderSide(width: 0, style: BorderStyle.none)
                                  //                           ),
                                  //                           focusedBorder: OutlineInputBorder(
                                  //                             borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0.3)),
                                  //                             borderRadius: BorderRadius.all(Radius.circular(8))
                                  //                           ),
                                  //                         ),
                                  //                       ),
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //             )
                                  //           ],
                                  //         ),
                                  //       ),
                                  //       Divider(
                                  //         color: Color.fromRGBO(252, 252, 252, 0.5),
                                  //       )
                                  //     ],
                                  //   ),
                                  //   isExpanded: openPanels[2],
                                  //   backgroundColor: Color.fromRGBO(252, 252, 252, 0.00),
                                  // ),
                                  // ExpansionPanel(
                                  //   headerBuilder: (context, isOpen) {
                                  //     return Padding(
                                  //       padding: const EdgeInsets.only(left: 5),
                                  //       child: Align(
                                  //         alignment: Alignment.centerLeft,
                                  //         child: Text(
                                  //           "Resources",
                                  //           style: TextStyle(
                                  //             fontSize: 16,
                                  //             fontWeight: FontWeight.w700,
                                  //             color: Color.fromRGBO(252, 252, 252, 0.7)
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     );
                                  //   },
                                  //   body: Column(
                                  //     children: () {
                                  //         List<Widget> res = [];

                                  //         for (int i = 0; i < resourcesCount; i++) {
                                  //           res.add(
                                  //             Padding(
                                  //               padding: EdgeInsets.only(bottom: i + 1 == resourcesCount ? 0 : 10),
                                  //               child: Container(
                                  //                 height: 50,
                                  //                 decoration: BoxDecoration(
                                  //                   color: Color.fromRGBO(252, 252, 252, 0.08),
                                  //                   borderRadius: BorderRadius.circular(8)
                                  //                 ),
                                  //                 child: Row(
                                  //                   children: [
                                  //                     Flexible(
                                  //                       flex: 2,
                                  //                       child: TextField(
                                  //                         controller: resourceNames[i],
                                  //                         onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                                  //                         textAlignVertical: TextAlignVertical.center,
                                  //                         cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                                  //                         cursorHeight: 20,
                                  //                         style: const TextStyle(
                                  //                           color: Color.fromRGBO(252, 252, 252, 0.7),
                                  //                           height: 2.25,
                                  //                           fontWeight: FontWeight.w700,
                                  //                           fontSize: 18,
                                  //                         ),
                                  //                         decoration: const InputDecoration(
                                  //                           contentPadding: EdgeInsets.only(left: 10),
                                  //                           isDense: true,
                                  //                           filled: true,
                                  //                           fillColor: Color.fromRGBO(62, 62, 62, 1),
                                  //                           hintText: "Name",
                                  //                           hintStyle: TextStyle(
                                  //                             color: Color.fromRGBO(252, 252, 252, 0.5),
                                  //                           ),
                                  //                           border: OutlineInputBorder(
                                  //                             borderRadius: BorderRadius.all(Radius.circular(8)),
                                  //                             borderSide: BorderSide(width: 0, style: BorderStyle.none)
                                  //                           ),
                                  //                           focusedBorder: OutlineInputBorder(
                                  //                             borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0.3)),
                                  //                             borderRadius: BorderRadius.all(Radius.circular(8))
                                  //                           ),
                                  //                         ),
                                  //                       ),
                                  //                     ),
                                  //                     DropdownMenu(
                                  //                       width: 125,
                                  //                       initialSelection: resourceTypes[i],
                                  //                       enableSearch: false,
                                  //                       dropdownMenuEntries: const [
                                  //                         DropdownMenuEntry(value: 0, label: "Financial"),
                                  //                         DropdownMenuEntry(value: 1, label: "Human"),
                                  //                         DropdownMenuEntry(value: 2, label: "Physical"),
                                  //                         DropdownMenuEntry(value: 3, label: "Other")
                                  //                       ],
                                  //                       onSelected: (value) {
                                  //                         resourceTypes[i] = value!;
                                  //                       },
                                  //                       textStyle: const TextStyle(
                                  //                         fontSize: 18,
                                  //                         fontWeight: FontWeight.w700,
                                  //                         color: Color.fromRGBO(252, 252, 252, 0.7)
                                  //                       ),
                                  //                       menuStyle: MenuStyle(
                                  //                         surfaceTintColor: WidgetStatePropertyAll(Color.fromRGBO(252, 252, 252, 0.95)),
                                  //                         backgroundColor: WidgetStatePropertyAll(Color.fromRGBO(62, 62, 62, 1)),
                                  //                         shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                  //                           borderRadius: BorderRadius.circular(8),
                                  //                         ))
                                  //                       ),
                                  //                       inputDecorationTheme: InputDecorationTheme(
                                  //                         contentPadding: EdgeInsets.only(left: 10),
                                  //                         isDense: true,
                                  //                         constraints: BoxConstraints.tight(Size.fromHeight(42)),
                                  //                         outlineBorder: BorderSide(
                                  //                           color: Color.fromRGBO(252, 252, 252, 0.95)
                                  //                         ),
                                  //                         border: OutlineInputBorder(
                                  //                           borderRadius: BorderRadius.circular(8)
                                  //                         ),
                                  //                         fillColor: Color.fromRGBO(62, 62, 62, 1),
                                  //                         filled: true,
                                  //                         iconColor: Color.fromRGBO(252, 252, 252, 0.95),
                                  //                         labelStyle: TextStyle(
                                  //                           fontSize: 18,
                                  //                           fontWeight: FontWeight.w700,
                                  //                           color: Color.fromRGBO(252, 252, 252, 0.95)
                                  //                         )
                                  //                       ),
                                  //                       trailingIcon: Transform.translate(
                                  //                         offset: Offset(0, -7),
                                  //                         child: Icon(
                                  //                           Icons.arrow_drop_down_rounded,
                                  //                           color: Color.fromRGBO(252, 252, 252, 0.95),
                                  //                           size: 32,
                                  //                         ),
                                  //                       ),
                                  //                       // controller: resourceTypes[i],
                                  //                       // onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                                  //                       // textAlignVertical: TextAlignVertical.center,
                                  //                       // cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                                  //                       // cursorHeight: 20,
                                  //                       // style: const TextStyle(
                                  //                       //   color: Color.fromRGBO(252, 252, 252, 0.7),
                                  //                       //   height: 2.25,
                                  //                       //   fontWeight: FontWeight.w700,
                                  //                       //   fontSize: 18,
                                  //                       // ),
                                  //                       // decoration: const InputDecoration(
                                  //                       //   contentPadding: EdgeInsets.only(left: 20),
                                  //                       //   isDense: true,
                                  //                       //   filled: true,
                                  //                       //   fillColor: Color.fromRGBO(62, 62, 62, 1),
                                  //                       //   hintText: "Name",
                                  //                       //   hintStyle: TextStyle(
                                  //                       //     color: Color.fromRGBO(39, 39, 39, 0.75),
                                  //                       //   ),
                                  //                       //   border: OutlineInputBorder(
                                  //                       //     borderRadius: BorderRadius.all(Radius.circular(8)),
                                  //                       //     borderSide: BorderSide(width: 0, style: BorderStyle.none)
                                  //                       //   ),
                                  //                       //   focusedBorder: OutlineInputBorder(
                                  //                       //     borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0.3)),
                                  //                       //     borderRadius: BorderRadius.all(Radius.circular(8))
                                  //                       //   ),
                                  //                       // ),
                                  //                     ),
                                  //                     Flexible(
                                  //                       flex: 1,
                                  //                       child: TextField(
                                  //                         controller: resourceAmounts[i],
                                  //                         onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                                  //                         textAlignVertical: TextAlignVertical.center,
                                  //                         cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                                  //                         cursorHeight: 20,
                                  //                         keyboardType: TextInputType.number,
                                  //                         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  //                         style: const TextStyle(
                                  //                           color: Color.fromRGBO(252, 252, 252, 0.7),
                                  //                           height: 2.25,
                                  //                           fontWeight: FontWeight.w700,
                                  //                           fontSize: 18,
                                  //                         ),
                                  //                         decoration: const InputDecoration(
                                  //                           contentPadding: EdgeInsets.only(left: 10),
                                  //                           isDense: true,
                                  //                           filled: true,
                                  //                           fillColor: Color.fromRGBO(62, 62, 62, 1),
                                  //                           hintText: "Amount",
                                  //                           hintStyle: TextStyle(
                                  //                             color: Color.fromRGBO(252, 252, 252, 0.5),
                                  //                           ),
                                  //                           border: OutlineInputBorder(
                                  //                             borderRadius: BorderRadius.all(Radius.circular(8)),
                                  //                             borderSide: BorderSide(width: 0, style: BorderStyle.none)
                                  //                           ),
                                  //                           focusedBorder: OutlineInputBorder(
                                  //                             borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0.3)),
                                  //                             borderRadius: BorderRadius.all(Radius.circular(8))
                                  //                           ),
                                  //                         ),
                                  //                       ),
                                  //                     ),
                                  //                     Center(
                                  //                       child: IconButton(
                                  //                         icon: Icon(
                                  //                           Icons.close_rounded,
                                  //                           color: Color.fromRGBO(252, 252, 252, 0.7),
                                  //                           size: 26,
                                  //                         ),
                                  //                         onPressed: () { deleteResource(i); },
                                  //                       ),
                                  //                     )
                                  //                   ],
                                  //                 ),
                                  //               ),
                                  //             )
                                  //           );
                                  //         }

                                  //         res.add(
                                  //           TextButton(
                                  //             onPressed: addResource,
                                  //             child: SizedBox(
                                  //               width: 200,
                                  //               child: Container(
                                  //                 decoration: BoxDecoration(
                                  //                   borderRadius: BorderRadius.circular(8),
                                  //                   color: Color.fromRGBO(252, 252, 252, 0.08)
                                  //                 ),
                                  //                 child: Padding(
                                  //                   padding: const EdgeInsets.only(left: 5, right: 10),
                                  //                   child: Row(
                                  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //                     children: [
                                  //                       Align(
                                  //                         alignment: Alignment.centerLeft,
                                  //                         child: Icon(
                                  //                           Icons.add_rounded,
                                  //                           color: Color.fromRGBO(252, 252, 252, 0.8),
                                  //                           size: 32,
                                  //                         ),
                                  //                       ),
                                  //                       Align(
                                  //                         alignment: Alignment.centerRight,
                                  //                         child: Text(
                                  //                           "Add Resource",
                                  //                           style: TextStyle(
                                  //                             fontSize: 20,
                                  //                             fontWeight: FontWeight.w700,
                                  //                             color: Color.fromRGBO(252, 252, 252, 0.8),
                                  //                           ),
                                  //                         ),
                                  //                       )
                                  //                     ],
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //           )
                                  //         );

                                  //         res.add(
                                  //           Divider(
                                  //             color: Color.fromRGBO(252, 252, 252, 0.5),
                                  //           )
                                  //         );

                                  //         return res;
                                  //       }()
                                  //   ),
                                  //   isExpanded: openPanels[3],
                                  //   backgroundColor: Color.fromRGBO(252, 252, 252, 0.00),
                                  // ),
                                ],
                                expandedHeaderPadding: EdgeInsets.all(0),
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