import 'package:daycare_parent/models/student_model.dart';
import 'package:daycare_parent/services/firestore_service.dart';
import 'package:flutter/material.dart';
 

class StudentViewModel extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<Student> students = [];
  bool isLoading = false;

  Future<void> fetchStudents(String email) async {
    isLoading = true;
    notifyListeners();
    students = await _service.fetchStudentsByEmail(email);
    isLoading = false;
    notifyListeners();
  }
}
