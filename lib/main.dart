import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'listdata.dart';
import 'package:provider/provider.dart';
import 'model/students.dart';

late double screenWidth;
late double screenHeight;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
      ),
      home: const MyApp(),
    ),
  );
}

class SelectedSubject extends ChangeNotifier {
  // String selectedSj = listSubjects.first;
  // void changeSelected(String value){
  //   selectedSj = value;
  //   notifyListeners();
  // }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

String slSubject = listSubjects.first;

class _MyAppState extends State<MyApp> {
  final snackBarCreate = SnackBar(
      content:
          const Row(children: [Text("Create Successfully!"), Icon(Icons.done)]),
      action: SnackBarAction(label: "OK", onPressed: () {}));

  Future<void> _displayDialogCreate(BuildContext context) async {
    TextEditingController studentName = TextEditingController();
    TextEditingController studentGPA = TextEditingController();
    String? errName, errGPA;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStateForDialog) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(
                    Icons.person_2_outlined,
                    color: Colors.blue,
                  ),
                  Text(
                    "Create a new student",
                    style: TextStyle(fontSize: 20, color: Colors.blue),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        maxLength: 10,
                        style: const TextStyle(color: Colors.lightGreen),
                        decoration: InputDecoration(
                            labelStyle:
                                const TextStyle(color: Colors.lightGreen),
                            labelText: "Student's name",
                            errorText: errName,
                            errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.redAccent),
                                borderRadius: BorderRadius.circular(13)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.redAccent, width: 2),
                                borderRadius: BorderRadius.circular(13)),
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.lightGreen),
                                borderRadius: BorderRadius.circular(13)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.green, width: 2),
                                borderRadius: BorderRadius.circular(13))),
                        controller: studentName,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const MyDropdownButton(),
                      const SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        style: const TextStyle(color: Colors.lightGreen),
                        decoration: InputDecoration(
                            labelStyle:
                                const TextStyle(color: Colors.lightGreen),
                            labelText: "GPA",
                            errorText: errGPA,
                            errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.redAccent),
                                borderRadius: BorderRadius.circular(13)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.redAccent, width: 2),
                                borderRadius: BorderRadius.circular(13)),
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 23, horizontal: 13),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 2, color: Colors.lightGreen),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.green, width: 2),
                              borderRadius: BorderRadius.circular(13),
                            )),
                        controller: studentGPA,
                        keyboardType: TextInputType.number,
                        cursorColor: Colors.lightGreen,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      slSubject = listSubjects.first;
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
                ElevatedButton(
                    onPressed: () {
                      if (studentName.text.isEmpty) {
                        setStateForDialog(() {
                          errName = "Student's name is empty";
                        });
                      } else if (studentGPA.text.isEmpty) {
                        setStateForDialog(() {
                          errName = null;
                          errGPA = "GPA is empty";
                        });
                      } else {
                        errName = null;
                        errGPA = null;
                        Navigator.pop(context);
                        createData(studentName.text, slSubject,
                            double.parse(studentGPA.text));
                        slSubject = listSubjects.first;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(snackBarCreate);
                      }
                    },
                    child: const Text("Create")),
              ],
            );
          });
        });
  }

  final snackBarUpdate = SnackBar(
      content:
          const Row(children: [Text("Update Successfully!"), Icon(Icons.done)]),
      action: SnackBarAction(label: "OK", onPressed: () {}));

  Future<void> _displayDialogUpdate(BuildContext context, String id,
      String name, String program, double gpa) async {
    TextEditingController studentName = TextEditingController();
    TextEditingController studentGPA = TextEditingController();
    studentName.text = name;
    slSubject = program;
    studentGPA.text = gpa.toString();
    String? errName, errGPA;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStateForDialog) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(
                    Icons.person_2_outlined,
                    color: Colors.blue,
                  ),
                  Text(
                    "Update: $name",
                    style: const TextStyle(fontSize: 20, color: Colors.blue),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        maxLength: 10,
                        style: const TextStyle(color: Colors.lightGreen),
                        decoration: InputDecoration(
                            labelStyle:
                                const TextStyle(color: Colors.lightGreen),
                            labelText: "Student's name",
                            errorText: errName,
                            errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.redAccent),
                                borderRadius: BorderRadius.circular(13)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.redAccent, width: 2),
                                borderRadius: BorderRadius.circular(13)),
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.lightGreen),
                                borderRadius: BorderRadius.circular(13)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.green, width: 2),
                                borderRadius: BorderRadius.circular(13))),
                        controller: studentName,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const MyDropdownButton(),
                      const SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        style: const TextStyle(color: Colors.lightGreen),
                        decoration: InputDecoration(
                            labelStyle:
                                const TextStyle(color: Colors.lightGreen),
                            labelText: "GPA",
                            errorText: errGPA,
                            errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.redAccent),
                                borderRadius: BorderRadius.circular(13)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.redAccent, width: 2),
                                borderRadius: BorderRadius.circular(13)),
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 23, horizontal: 13),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 2, color: Colors.lightGreen),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.green, width: 2),
                              borderRadius: BorderRadius.circular(13),
                            )),
                        controller: studentGPA,
                        keyboardType: TextInputType.number,
                        cursorColor: Colors.lightGreen,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      slSubject = listSubjects.first;
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
                ElevatedButton(
                    onPressed: () {
                      if (studentName.text.isEmpty) {
                        setStateForDialog(() {
                          errName = "Student's name is empty";
                        });
                      } else if (studentGPA.text.isEmpty) {
                        setStateForDialog(() {
                          errName = null;
                          errGPA = "GPA is empty";
                        });
                      } else {
                        errName = null;
                        errGPA = null;
                        Navigator.pop(context);
                        updateData(id, studentName.text, slSubject,
                            double.parse(studentGPA.text));
                        slSubject = listSubjects.first;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(snackBarCreate);
                      }
                    },
                    child: const Text("Update")),
              ],
            );
          });
        });
  }

  createData(String name, String program, double gpa) {
    var randomColor = Random();
    String mycolor = listColor[randomColor.nextInt(listColor.length)].cl;
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyStudents").doc();
    var student = Student(
        studentName: name,
        studentProgramID: program,
        studentGPA: gpa,
        stuColor: mycolor);
    documentReference.set(student.toMap()).whenComplete(() => readData());
  }

  readData() async {
    QuerySnapshot<Object?> documentReference =
        await FirebaseFirestore.instance.collection("MyStudents").get();
    for (QueryDocumentSnapshot value in documentReference.docs) {
      updateStudentIdThenCreate(value.id);
    }
  }

  updateStudentIdThenCreate(String id) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyStudents").doc(id);
    Map<String, String> assignID = {"studentID": id};
    documentReference
        .set(assignID, SetOptions(merge: true))
        // ignore: avoid_print
        .whenComplete(() => print("update successfully"));
  }

  updateData(String id, String name, String program, double gpa) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyStudents").doc(id);
    Map<String, dynamic> updateStudent = {
      "studentName": name,
      "studentProgramID": program,
      "studentGPA": gpa
    };
    documentReference
        .update(updateStudent)
        // ignore: avoid_print
        .whenComplete(() => print("$updateStudent updated"));
  }

  deleteData(String id) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyStudents").doc(id);
    documentReference.delete();
  }

  final snackBar = SnackBar(
      content:
          const Row(children: [Text("Delete Successfully!"), Icon(Icons.done)]),
      action: SnackBarAction(label: "OK", onPressed: () {}));

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _displayDialogCreate(context);
        },
        backgroundColor: const Color(0xFFFF80AB),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF80AB),
        title: const Text("Manage Students"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("MyStudents")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Đã xảy ra lỗi: ${snapshot.error}");
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("Không có dữ liệu.");
                } else {
                  final documents = snapshot.data!.docs;
                  documents.sort((a, b) {
                    double gpaA = a["studentGPA"];
                    double gpaB = b["studentGPA"];
                    return gpaB.compareTo(gpaA);
                  });
                  return Expanded(
                    child: ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final document = documents[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: Color(
                                int.parse(document["stuColor"], radix: 16)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: GestureDetector(
                            onTap: () => {},
                            child: Column(
                              children: [
                                Slidable(
                                  key: const ValueKey(0),
                                  endActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (value) {
                                          _displayDialogUpdate(
                                              context,
                                              document["studentID"],
                                              document["studentName"],
                                              document["studentProgramID"],
                                              document["studentGPA"]);
                                        },
                                        backgroundColor: Colors.yellow,
                                        foregroundColor: Colors.white,
                                        icon: Icons.update,
                                        label: 'Update',
                                      ),
                                      SlidableAction(
                                        borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        onPressed: (_) => showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                AlertDialog(
                                                  title: const Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.red),
                                                  ),
                                                  content: const Text(
                                                      "Do you want to delete this student ?"),
                                                  actions: [
                                                    OutlinedButton(
                                                      onPressed: () => {
                                                        Navigator.pop(context)
                                                      },
                                                      child: const Text(
                                                        "Cancel",
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                        onPressed: () => {
                                                              deleteData(document[
                                                                  "studentID"]),
                                                              Navigator.pop(
                                                                  context),
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      snackBar)
                                                            },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                backgroundColor:
                                                                    Colors.red),
                                                        child:
                                                            const Text("OK")),
                                                  ],
                                                )),
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: 'Delete',
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: Color(int.parse(
                                              document["stuColor"],
                                              radix: 16)),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(int.parse(
                                                      document["stuColor"],
                                                      radix: 16))
                                                  .withOpacity(0.5),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: const Offset(0, 3),
                                            )
                                          ]),
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20, horizontal: 20),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Row(
                                                children: [
                                                  const Image(
                                                    image: NetworkImage(
                                                        "https://cdn-icons-png.flaticon.com/512/1326/1326405.png"),
                                                    height: 80,
                                                    width: 80,
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${document["studentName"]}',
                                                        style: const TextStyle(
                                                            fontSize: 24,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                Colors.white),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            "Subject: ",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 17),
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                screenWidth / 5,
                                                            child: Text(
                                                              '${document["studentProgramID"]}',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 17),
                                                              softWrap: false,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )),
                                          Container(
                                            height: 80,
                                            width: 1,
                                            color: Colors.white,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Center(
                                              child: Column(
                                                children: [
                                                  const Text(
                                                    "GPA",
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    "${document["studentGPA"]}",
                                                    style: const TextStyle(
                                                        fontSize: 30,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

class MyDropdownButton extends StatefulWidget {
  const MyDropdownButton({super.key});

  @override
  State<MyDropdownButton> createState() => _MyDropdownButtonState();
}

class _MyDropdownButtonState extends State<MyDropdownButton> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      borderRadius: BorderRadius.circular(10),
      iconDisabledColor: Colors.lightGreen,
      iconEnabledColor: Colors.green,
      decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 2, color: Colors.lightGreen),
            borderRadius: BorderRadius.circular(11),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 2, color: Colors.lightGreen),
            borderRadius: BorderRadius.circular(11),
          )),
      items: listSubjects.map((String value) {
        return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(color: Colors.lightGreen),
            ));
      }).toList(),
      value: slSubject,
      onChanged: (String? value) {
        setState(() {
          slSubject = value!;
          // print("CHANGE: $dropdownValue");
        });
      },
    );
  }
}
