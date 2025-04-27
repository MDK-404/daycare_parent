import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daycare_parent/services/get_server_key.dart';
import 'package:daycare_parent/services/notification_service.dart';
import 'package:daycare_parent/view_models/student_view_model.dart';
import 'package:daycare_parent/views/student_vaccination_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'edit_student_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isButtonPressed = false; // Button pressed state

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Future.microtask(() {
        Provider.of<StudentViewModel>(
          context,
          listen: false,
        ).fetchStudents(user.email ?? '');
      });
    }
  }

  void _handleButtonPress() async {
    setState(() => isButtonPressed = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => isButtonPressed = false);

    try {
      final accessToken = await GetServerKey().getServerKeyToken();

      // Step 1: Get current user email
      final currentUser = FirebaseAuth.instance.currentUser;
      final currentUserEmail = currentUser?.email;
      if (currentUserEmail == null) throw Exception("User not logged in");

      // Step 2: Fetch students linked to this parent
      final studentsSnapshot =
          await FirebaseFirestore.instance
              .collection('students')
              .where('parentEmail', isEqualTo: currentUserEmail)
              .get();

      final studentNames =
          studentsSnapshot.docs
              .map((doc) => doc.data()['name'] as String)
              .toList();

      if (studentNames.isEmpty) {
        throw Exception("No students found for this parent");
      }

      final studentList = studentNames.join(', ');
      final messageBody = "Parent(s) of $studentList are coming to daycare!";

      // Step 3: Fetch dcOwner and admin users
      final adminSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'dcOwner')
              .get();

      if (adminSnapshot.docs.isEmpty) {
        throw Exception('No admin or dcOwner found!');
      }

      bool notificationSent = false;

      for (var adminDoc in adminSnapshot.docs) {
        final data = adminDoc.data();
        final adminDeviceToken = data['deviceToken'];

        //print statemnet to check if the device token is null or empty
        // if (adminDeviceToken == null || adminDeviceToken.isEmpty) {
        //   print("No device token for ${data['name']}");
        //   continue;
        // }

        // Step 4: Send notification
        await NotificationSender().sendNotification(
          deviceToken: adminDeviceToken,
          title: "Daycare Alert",
          body: messageBody,
          accessToken: accessToken,
        );

        // Step 5: Save to Firestore
        await FirebaseFirestore.instance.collection('notifications').add({
          'title': 'Daycare Alert',
          'body': messageBody,
          'timestamp': FieldValue.serverTimestamp(),
          'toRole': data['role'],
          'sentTo': data['email'],
          'fromParent': currentUserEmail,
          'studentList': studentNames,
        });

        notificationSent = true;
      }

      if (notificationSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification sent to Admin(s)!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No valid admin device tokens found.')),
        );
      }
    } catch (e) {
      print("Error sending notification: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send notification')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StudentViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Students")),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            "Notify Daycare Admin",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _handleButtonPress,
            style: ElevatedButton.styleFrom(
              backgroundColor: isButtonPressed ? Colors.green : Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Send Notification",
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      itemCount: viewModel.students.length,
                      itemBuilder: (context, index) {
                        final student = viewModel.students[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                student.profileImageUrl ?? '',
                              ),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(student.name),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => EditStudentScreen(
                                              student: student,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Date of Birth: ${student.dobString}"),
                                Text("Age: ${student.ageString}"),
                                Text("Daycare: ${student.daycare}"),
                                Row(
                                  children: [
                                    const Text("Vaccination due: "),
                                    GestureDetector(
                                      onTap: () {
                                        // Handle tap to view vaccination details
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    StudentVaccinationDetailScreen(
                                                      student: student,
                                                    ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        color:
                                            student.vaccinationStatus ==
                                                    "overdue"
                                                ? Colors.red
                                                : Colors.green,
                                        child: Text(
                                          student.vaccinationStatus == "overdue"
                                              ? "Vaccination overdue"
                                              : "Up to date",
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
