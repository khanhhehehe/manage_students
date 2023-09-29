import 'package:flutter/material.dart';
class Student {
  String? studentID;
  late String studentName, studentProgramID;
  late double studentGPA;
  late String stuColor;

  Student(
      {required this.studentName,
      required this.studentProgramID,
      required this.studentGPA,
      required this.stuColor});

  Student.setidstudent(String stuID) {
    studentID = stuID;
  }

  Map<String, dynamic> toMap() {
    return {
      'studentName': studentName,
      'studentProgramID': studentProgramID,
      'studentGPA': studentGPA,
      'stuColor': stuColor,
    };
  }
}
