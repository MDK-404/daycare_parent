import 'package:daycare_parent/models/student_model.dart';
import 'package:flutter/material.dart';

class EditStudentScreen extends StatefulWidget {
  final Student student;
  const EditStudentScreen({super.key, required this.student});

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  late TextEditingController nameController;
  late TextEditingController dobController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.student.name);
    dobController = TextEditingController(text: widget.student.dobString);
    emailController = TextEditingController(text: widget.student.parentEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Student")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            widget.student.profileImageUrl != null
                ? Image.network(
                  widget.student.profileImageUrl!,
                  height: 100,
                  width: 400,
                  //  fit: BoxFit.cover,
                )
                : const Placeholder(fallbackHeight: 150),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: dobController,
              decoration: const InputDecoration(labelText: "Date of Birth"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Parent Email"),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Save"),
              onPressed: () {
                // TODO: update logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
