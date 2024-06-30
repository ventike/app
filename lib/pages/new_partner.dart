import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:ventike/api/partners_data.dart';
import 'package:ventike/utils/args.dart';
import 'package:ventike/utils/vars.dart';
import 'package:ventike/widgets/navbar.dart';

class NewPartnerPage extends StatefulWidget {
  const NewPartnerPage({super.key});

  @override
  State<NewPartnerPage> createState() => _NewPartnerPageState();
}

class _NewPartnerPageState extends State<NewPartnerPage> {
  String userHash = "";
  int role = 2;
  String? profilePicture;
  String? originalImage;

  int id = -1;
  String name = "";
  String description = "";
  int type = -1;
  String email = "";
  String phone = "";
  String image = "";
  String individualFirstName = "";
  String individualLastName = "";
  String individualEmail = "";
  String individualPhone = "";
  List<dynamic> tags = []; // 
  List<dynamic> resources = []; //

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final TextEditingController individualFirstNameController = TextEditingController();
  final TextEditingController individualLastNameController = TextEditingController();
  final TextEditingController individualEmailController = TextEditingController();
  final TextEditingController individualPhoneController = TextEditingController();

  final TextEditingController tagsContoller = TextEditingController();

  Set<int> partnerType = {0};

  // List<String> tagNames = [];

  bool firstRun = true;
  List<bool> openPanels = [false, false, false, false];

  int resourcesCount = -1;
  List<TextEditingController> resourceNames = [];
  List<TextEditingController> resourceAmounts = [];

  List<int> resourceTypes = [];

  String errorMessage = "";
  double errorMessagePadding = 0;
  bool saveButtonEnabled = true;
  bool deleteButtonEnabled = true;

  ScrollController scrollController = ScrollController();

  BuildContext getContext() {
    return context;
  }

  void save() {
    String name = nameController.text;
    String description = descriptionController.text;
    String email = emailController.text;
    String phone = phoneController.text;

    int type = partnerType.first;
    // String? imageVal = image == placeholderPartnerImage ? null : image;
    String? imageVal = originalImage;

    String individualFirstName = individualFirstNameController.text;
    String individualLastName = individualLastNameController.text;
    String individualEmail = individualEmailController.text;
    String individualPhone = individualPhoneController.text;

    List<String> tags = tagsContoller.text.split(" ");
    
    List<String> resourceNamesVal = [];
    List<int> resourceTypesVal = [];
    List<int> resourceAmountsVal = [];

    for (int i = 0; i < resourcesCount; i++) {
      resourceNamesVal.add(resourceNames[i].text);
      resourceAmountsVal.add(int.parse(resourceAmounts[i].text));
      resourceTypesVal.add(resourceTypes[i]);

    }

    setState(() {
      errorMessage = "";
      errorMessagePadding = 0;
      saveButtonEnabled = false;
    });

    if (name == "" || description == "" || email == "" || phone == "" || individualFirstName == "" || individualLastName == "" || individualEmail == "" || individualPhone == "") {
      setState(() {
        errorMessage = "Please fill all fields";
        errorMessagePadding = 15;
        scrollController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
        saveButtonEnabled = true;
      });
      return;
    }

    addPartner(userHash, name, description, email, phone, type, imageVal, individualFirstName, individualLastName, individualEmail, individualPhone, tags, resourceNamesVal, resourceTypesVal, resourceAmountsVal).then((res) {
      print(res.statusCode);
      print(res.body);

      if (res.statusCode == 200) {
        Navigator.of(context).popAndPushNamed('/partners', arguments: Arguments(userHash, role, profilePicture));
      } else if (res.statusCode == 405) {
        setState(() {
          errorMessage = "Invalid Email(s)";
          errorMessagePadding = 15;
          scrollController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
          saveButtonEnabled = true;
        });
        return;
      } else if (res.statusCode == 406) {
        setState(() {
          errorMessage = "Invalid Phone Number(s)";
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
    });
  }

  void updateType(Set<int> types) {
    setState(() {
      partnerType = types;
    });
  }

  void getImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', "png"]
      );

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        image = Base64Encoder.urlSafe().convert(file.readAsBytesSync());
      });
    } else {
      // User canceled the picker
    }
  }

  void addResource() {
    setState(() {
      resourceNames.add(TextEditingController());
      resourceAmounts.add(TextEditingController());
      resourceTypes.add(3);
      resourcesCount += 1;
    });
  }

  void deleteResource(int i) {
    setState(() {
      resourceNames.removeAt(i);
      resourceTypes.removeAt(i);
      resourceAmounts.removeAt(i);
      resourcesCount -= 1;
    });
  }

  // void getImageString() async {
  //   ByteData bytes = await rootBundle.load('assets/images/questionmark.png');
  //   var buffer = bytes.buffer;
  //   var m = base64.encode(Uint8List.view(buffer));
  //   await Clipboard.setData(ClipboardData(text: m));
  //   // final data = await rootBundle.load('assets/images/questionmark.png');
  //   // await Clipboard.setData(ClipboardData(text:(const Base64Encoder.urlSafe().convert(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes)))));
  // }

  @override
  Widget build(BuildContext context) {
    if (firstRun) {
      final args = ModalRoute.of(context)!.settings.arguments as Arguments;

      userHash = args.userHash;
      role = args.role;
      profilePicture = args.profilePicture;

      image = placeholderPartnerImage;

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
                    "Add Partner",
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
                                      "Phone:",
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
                                              controller: phoneController,
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
                                      "Type:",
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
                                          child: SegmentedButton(
                                            segments: [
                                              ButtonSegment<int>(
                                                value: 0,
                                                icon: Icon(
                                                  Icons.business_rounded,
                                                  size: 20,
                                                ),
                                                // label: Text("Business")
                                              ),
                                              ButtonSegment<int>(
                                                value: 1,
                                                icon: Icon(
                                                  Icons.diversity_3_rounded,
                                                  size: 20,
                                                ),
                                                // label: Text("Community")
                                              ),
                                              ButtonSegment<int>(
                                                value: 2,
                                                icon: Icon(
                                                  Icons.school_rounded,
                                                  size: 20,
                                                ),
                                                // label: Text("Community")
                                              ),
                                              ButtonSegment<int>(
                                                value: 3,
                                                icon: Icon(
                                                  Icons.pending_rounded,
                                                  size: 20,
                                                ),
                                                // label: Text("Community")
                                              )
                                            ],
                                            selected: partnerType,
                                            onSelectionChanged: updateType,
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
                            Divider(
                              color: Color.fromRGBO(252, 252, 252, 0.5),
                            ),
                            FractionallySizedBox(
                              widthFactor: 1,
                              child: ExpansionPanelList(
                                expansionCallback: (i, isOpen) {
                                  setState(() {
                                    openPanels[i] = isOpen;
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
                                            "Image",
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
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 20, right: 20),
                                                child: TextButton(
                                                  onPressed: getImage,
                                                  child: Text(
                                                    "Change Image",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w700,
                                                      color: Color.fromRGBO(252, 252, 252, 0.7)
                                                    ),
                                                    ),
                                                  style: TextButton.styleFrom(
                                                    backgroundColor: Color.fromRGBO(62, 62, 62, 1),
                                                    padding: EdgeInsets.all(0),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8)
                                                    )
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: AspectRatio(
                                                aspectRatio: 1,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(8),
                                                    color: const Color.fromRGBO(252, 252, 252, 0.08)
                                                  ),
                                                  clipBehavior: Clip.hardEdge,
                                                  child: Image.memory(
                                                    base64.decode(image),
                                                    fit: BoxFit.cover
                                                  ),
                                                  // child: Image.asset(
                                                  //   'assets/images/questionmark.png',
                                                  //   fit: BoxFit.cover,
                                                  // ),
                                                ),
                                              ),
                                            )
                                            // Image.memory(base64Decode(base64String))
                                          ],
                                        ),
                                        Divider(
                                          color: Color.fromRGBO(252, 252, 252, 0.5),
                                        )
                                      ],
                                    ),
                                    isExpanded: openPanels[0],
                                    backgroundColor: Color.fromRGBO(252, 252, 252, 0.00),
                                  ),
                                  ExpansionPanel(
                                    headerBuilder: (context, isOpen) {
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Individual",
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
                                      children: [
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
                                                          controller: individualFirstNameController,
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
                                                          controller: individualLastNameController,
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
                                                          controller: individualEmailController,
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
                                                  "Phone:",
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
                                                          controller: individualPhoneController,
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
                                        Divider(
                                          color: Color.fromRGBO(252, 252, 252, 0.5),
                                        )
                                      ],
                                    ),
                                    isExpanded: openPanels[1],
                                    backgroundColor: Color.fromRGBO(252, 252, 252, 0.00),
                                  ),
                                  ExpansionPanel(
                                    headerBuilder: (context, isOpen) {
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Tags",
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
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 15),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                flex: 1,
                                                child: Text(
                                                  "Values:",
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
                                                          controller: tagsContoller,
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
                                        Divider(
                                          color: Color.fromRGBO(252, 252, 252, 0.5),
                                        )
                                      ],
                                    ),
                                    isExpanded: openPanels[2],
                                    backgroundColor: Color.fromRGBO(252, 252, 252, 0.00),
                                  ),
                                  ExpansionPanel(
                                    headerBuilder: (context, isOpen) {
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Resources",
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

                                          for (int i = 0; i < resourcesCount; i++) {
                                            res.add(
                                              Padding(
                                                padding: EdgeInsets.only(bottom: i + 1 == resourcesCount ? 0 : 10),
                                                child: Container(
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Color.fromRGBO(252, 252, 252, 0.08),
                                                    borderRadius: BorderRadius.circular(8)
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Flexible(
                                                        flex: 2,
                                                        child: TextField(
                                                          controller: resourceNames[i],
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
                                                            contentPadding: EdgeInsets.only(left: 10),
                                                            isDense: true,
                                                            filled: true,
                                                            fillColor: Color.fromRGBO(62, 62, 62, 1),
                                                            hintText: "Name",
                                                            hintStyle: TextStyle(
                                                              color: Color.fromRGBO(252, 252, 252, 0.5),
                                                            ),
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
                                                      DropdownMenu(
                                                        width: 125,
                                                        initialSelection: resourceTypes[i],
                                                        enableSearch: false,
                                                        dropdownMenuEntries: const [
                                                          DropdownMenuEntry(value: 0, label: "Financial"),
                                                          DropdownMenuEntry(value: 1, label: "Human"),
                                                          DropdownMenuEntry(value: 2, label: "Physical"),
                                                          DropdownMenuEntry(value: 3, label: "Other")
                                                        ],
                                                        onSelected: (value) {
                                                          resourceTypes[i] = value!;
                                                        },
                                                        textStyle: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w700,
                                                          color: Color.fromRGBO(252, 252, 252, 0.7)
                                                        ),
                                                        menuStyle: MenuStyle(
                                                          surfaceTintColor: WidgetStatePropertyAll(Color.fromRGBO(252, 252, 252, 0.95)),
                                                          backgroundColor: WidgetStatePropertyAll(Color.fromRGBO(62, 62, 62, 1)),
                                                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ))
                                                        ),
                                                        inputDecorationTheme: InputDecorationTheme(
                                                          contentPadding: EdgeInsets.only(left: 10),
                                                          isDense: true,
                                                          constraints: BoxConstraints.tight(Size.fromHeight(42)),
                                                          outlineBorder: BorderSide(
                                                            color: Color.fromRGBO(252, 252, 252, 0.95)
                                                          ),
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8)
                                                          ),
                                                          fillColor: Color.fromRGBO(62, 62, 62, 1),
                                                          filled: true,
                                                          iconColor: Color.fromRGBO(252, 252, 252, 0.95),
                                                          labelStyle: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.w700,
                                                            color: Color.fromRGBO(252, 252, 252, 0.95)
                                                          )
                                                        ),
                                                        trailingIcon: Transform.translate(
                                                          offset: Offset(0, -7),
                                                          child: Icon(
                                                            Icons.arrow_drop_down_rounded,
                                                            color: Color.fromRGBO(252, 252, 252, 0.95),
                                                            size: 32,
                                                          ),
                                                        ),
                                                        // controller: resourceTypes[i],
                                                        // onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                                                        // textAlignVertical: TextAlignVertical.center,
                                                        // cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                                                        // cursorHeight: 20,
                                                        // style: const TextStyle(
                                                        //   color: Color.fromRGBO(252, 252, 252, 0.7),
                                                        //   height: 2.25,
                                                        //   fontWeight: FontWeight.w700,
                                                        //   fontSize: 18,
                                                        // ),
                                                        // decoration: const InputDecoration(
                                                        //   contentPadding: EdgeInsets.only(left: 20),
                                                        //   isDense: true,
                                                        //   filled: true,
                                                        //   fillColor: Color.fromRGBO(62, 62, 62, 1),
                                                        //   hintText: "Name",
                                                        //   hintStyle: TextStyle(
                                                        //     color: Color.fromRGBO(39, 39, 39, 0.75),
                                                        //   ),
                                                        //   border: OutlineInputBorder(
                                                        //     borderRadius: BorderRadius.all(Radius.circular(8)),
                                                        //     borderSide: BorderSide(width: 0, style: BorderStyle.none)
                                                        //   ),
                                                        //   focusedBorder: OutlineInputBorder(
                                                        //     borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 0.3)),
                                                        //     borderRadius: BorderRadius.all(Radius.circular(8))
                                                        //   ),
                                                        // ),
                                                      ),
                                                      Flexible(
                                                        flex: 1,
                                                        child: TextField(
                                                          controller: resourceAmounts[i],
                                                          onTapOutside: (event) { FocusManager.instance.primaryFocus?.unfocus(); },
                                                          textAlignVertical: TextAlignVertical.center,
                                                          cursorColor: const Color.fromRGBO(39, 39, 39, 0.95),
                                                          cursorHeight: 20,
                                                          keyboardType: TextInputType.number,
                                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                          style: const TextStyle(
                                                            color: Color.fromRGBO(252, 252, 252, 0.7),
                                                            height: 2.25,
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 18,
                                                          ),
                                                          decoration: const InputDecoration(
                                                            contentPadding: EdgeInsets.only(left: 10),
                                                            isDense: true,
                                                            filled: true,
                                                            fillColor: Color.fromRGBO(62, 62, 62, 1),
                                                            hintText: "Amount",
                                                            hintStyle: TextStyle(
                                                              color: Color.fromRGBO(252, 252, 252, 0.5),
                                                            ),
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
                                                      Center(
                                                        child: IconButton(
                                                          icon: Icon(
                                                            Icons.close_rounded,
                                                            color: Color.fromRGBO(252, 252, 252, 0.7),
                                                            size: 26,
                                                          ),
                                                          onPressed: () { deleteResource(i); },
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            );
                                          }

                                          res.add(
                                            TextButton(
                                              onPressed: addResource,
                                              child: SizedBox(
                                                width: 200,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(8),
                                                    color: Color.fromRGBO(252, 252, 252, 0.08)
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 5, right: 10),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Icon(
                                                            Icons.add_rounded,
                                                            color: Color.fromRGBO(252, 252, 252, 0.8),
                                                            size: 32,
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Text(
                                                            "Add Resource",
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight.w700,
                                                              color: Color.fromRGBO(252, 252, 252, 0.8),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          );

                                          res.add(
                                            Divider(
                                              color: Color.fromRGBO(252, 252, 252, 0.5),
                                            )
                                          );

                                          return res;
                                        }()
                                    ),
                                    isExpanded: openPanels[3],
                                    backgroundColor: Color.fromRGBO(252, 252, 252, 0.00),
                                  ),
                                ],
                                expandedHeaderPadding: EdgeInsets.all(0),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: OutlinedButton(
                                        onPressed: saveButtonEnabled ? save : null,
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
                              )
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