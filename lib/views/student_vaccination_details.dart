import 'package:daycare_parent/models/student_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentVaccinationDetailScreen extends StatefulWidget {
  final Student student;

  const StudentVaccinationDetailScreen({super.key, required this.student});

  @override
  State<StudentVaccinationDetailScreen> createState() =>
      _StudentVaccinationDetailScreenState();
}

class _StudentVaccinationDetailScreenState
    extends State<StudentVaccinationDetailScreen> {
  late Student student;

  @override
  void initState() {
    super.initState();
    student = widget.student;
  }

  Future<void> _updateVaccineInFirebase(
    Vaccine vaccine,
    DateTime administeredDate,
  ) async {
    final docRef = FirebaseFirestore.instance
        .collection('students')
        .doc(student.id);

    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final vaccinesData = snapshot.data()?['vaccines'] ?? [];

    List<Map<String, dynamic>> updatedVaccines =
        (vaccinesData as List<dynamic>).map((v) {
          final vaccineMap = v as Map<String, dynamic>;
          if (vaccineMap['id'] == vaccine.id) {
            vaccineMap['administered'] = true;
            vaccineMap['administeredDate'] = administeredDate.toIso8601String();
          }
          return vaccineMap;
        }).toList();

    await docRef.update({'vaccines': updatedVaccines});
  }

  @override
  Widget build(BuildContext context) {
    final totalVaccines = student.vaccines.length;
    final completedVaccines =
        student.vaccines.where((v) => v.administered).length;

    return Scaffold(
      appBar: AppBar(title: Text(student.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(student.profileImageUrl ?? ''),
            ),
            const SizedBox(height: 12),
            Text(
              student.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Date of Birth: ${student.dobString}'),
            Text('Age: ${student.ageString}'),
            Text('Daycare: ${student.daycare}'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    student.vaccinationStatus == 'overdue'
                        ? Colors.red
                        : Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                student.vaccinationStatus == 'overdue'
                    ? 'Vaccination Overdue'
                    : 'Up to Date',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Vaccinations",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "$completedVaccines/$totalVaccines",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._buildVaccinationList(context, student.vaccines),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildVaccinationList(
    BuildContext context,
    List<Vaccine> vaccines,
  ) {
    final grouped = groupByCategory(vaccines);

    return grouped.entries.map((entry) {
      final vaccinesInCategory = entry.value;
      final completed = vaccinesInCategory.where((v) => v.administered).length;

      return ExpansionTile(
        title: Text(
          entry.key,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: completed != vaccinesInCategory.length,
        children:
            vaccinesInCategory.map((vaccine) {
              return ListTile(
                title: Text(vaccine.name),
                subtitle: Row(
                  children: [
                    Text(vaccine.status!.value),
                    const SizedBox(width: 8),
                    _getVaccineStatusIcon(vaccine.status!),
                  ],
                ),
                trailing:
                    vaccine.administered
                        ? Text(
                          "${vaccine.administeredDate!.day}/${vaccine.administeredDate!.month}/${vaccine.administeredDate!.year}",
                          style: const TextStyle(fontSize: 12),
                        )
                        : IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            final administeredDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );

                            if (administeredDate != null) {
                              final confirm = await showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Confirmation'),
                                      content: Text(
                                        'Are you sure to add this entry for "${vaccine.name}"?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    ),
                              );

                              if (confirm == true) {
                                await _updateVaccineInFirebase(
                                  vaccine,
                                  administeredDate,
                                );

                                // Update local state as well
                                setState(() {
                                  vaccine.administered = true;
                                  vaccine.administeredDate = administeredDate;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Vaccine updated successfully!',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
              );
            }).toList(),
      );
    }).toList();
  }

  Map<String, List<Vaccine>> groupByCategory(List<Vaccine> vaccines) {
    final Map<String, List<Vaccine>> data = {};
    for (var vaccine in vaccines) {
      if (!data.containsKey(vaccine.categoryName)) {
        data[vaccine.categoryName] = [];
      }
      data[vaccine.categoryName]!.add(vaccine);
    }
    return data;
  }

  Icon _getVaccineStatusIcon(VaccineStatus status) {
    IconData icon = Icons.pending;
    Color color = Colors.grey;

    switch (status) {
      case VaccineStatus.administered:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case VaccineStatus.due:
        icon = Icons.warning_amber_rounded;
        color = Colors.amber;
        break;
      case VaccineStatus.overdue:
        icon = Icons.error;
        color = Colors.red;
        break;
      case VaccineStatus.pending:
        break;
    }

    return Icon(icon, color: color, size: 16);
  }
}
