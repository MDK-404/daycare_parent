import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daycare_parent/models/student_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<List<Student>> fetchStudentsByEmail(String email) async {
    final snapshot =
        await _db
            .collection('students')
            .where('parentEmail', isEqualTo: email)
            .get();

    return snapshot.docs
        .map((doc) => Student.fromMap(doc.id, doc.data()))
        .toList();
  }
  Future<List<Vaccine>> fetchVaccines(String studentId) async {
  final docSnapshot = await FirebaseFirestore.instance
      .collection('students')
      .doc(studentId)
      .get();

  final vaccinesData = docSnapshot.data()?['vaccines'] ?? [];
  final vaccines = (vaccinesData as List<dynamic>)
      .map((v) => Vaccine.fromMap(v as Map<String, dynamic>))
      .toList();

  return vaccines;
}
}
