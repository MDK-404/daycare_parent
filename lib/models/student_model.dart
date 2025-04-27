import 'package:intl/intl.dart';

class Vaccine {
  final int id;
  final String name;
  final int categoryId;
  final String categoryName;
  final int minRequiredAge;
  final int? maxRequiredAge;
  bool administered;
  DateTime? administeredDate;

  Vaccine({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.minRequiredAge,
    this.maxRequiredAge,
    this.administered = false,
    this.administeredDate,
  });

  // Yeh raha tera status getter full logic ke sath:
  VaccineStatus get status {
    if (administered) {
      return VaccineStatus.administered;
    } else {
      final now = DateTime.now();
      final vaccineDueDate = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: (minRequiredAge * 30)));

      if (now.isAfter(vaccineDueDate)) {
        return VaccineStatus.overdue;
      } else {
        return VaccineStatus.due;
      }
    }
  }

  factory Vaccine.fromMap(Map<String, dynamic> map) {
    return Vaccine(
      id: map['id'],
      name: map['name'],
      categoryId: map['categoryId'],
      categoryName: map['categoryName'],
      minRequiredAge: map['minRequiredAge'],
      maxRequiredAge: map['maxRequiredAge'],
      administered: map['administered'] ?? false,
      administeredDate:
          map['administeredDate'] != null
              ? DateTime.parse(map['administeredDate'])
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'minRequiredAge': minRequiredAge,
      'maxRequiredAge': maxRequiredAge,
      'administered': administered,
      'administeredDate': administeredDate?.toIso8601String(),
    };
  }
}

class Student {
  final String id;
  final String name;
  final DateTime dob;
  final String daycare;
  final String vaccinationStatus;
  final String profileImageUrl;
  final String parentEmail;
  final List<Vaccine> vaccines;

  Student({
    required this.id,
    required this.name,
    required this.dob,
    required this.daycare,
    required this.vaccinationStatus,
    required this.profileImageUrl,
    required this.parentEmail,
    this.vaccines = const [],
  });

  String get dobString => DateFormat('yyyy-MM-dd').format(dob);

  String get ageString {
    if (dob == null) return '';

    final today = DateTime.now();
    int years = today.year - dob!.year;
    int months = today.month - dob!.month;
    int days = today.day - dob!.day;

    if (days < 0) {
      months--;
      days += DateTime(today.year, today.month, 0).day; // Last month days
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    String age = '';
    if (years > 0) {
      age += '$years year${years > 1 ? 's' : ''} ';
    }
    if (months > 0) {
      age += '$months month${months > 1 ? 's' : ''} ';
    }
    if (days > 0) {
      age += '$days day${days > 1 ? 's' : ''}';
    }

    return age.trim();
  }

   
  factory Student.fromMap(String id, Map<String, dynamic> data) {
    DateTime? dobParsed;
    if (data['dateOfBirth'] != null && data['dateOfBirth'] is String) {
      try {
        dobParsed = DateTime.parse(data['dateOfBirth']);
      } catch (e) {
        print('Error parsing date of birth: $e');
        dobParsed = DateTime(1970, 1, 1);
      }
    }

    String name = data['name'] ?? 'Unknown';
    String daycare = data['daycareName'] ?? 'Not Assigned';
    String profileImageUrl = data['profileImageUrl'] ?? '';
    String parentEmail = data['parentEmail'] ?? '';

    // Parse vaccines list
    List<Vaccine> vaccines = [];
    if (data['vaccines'] != null && data['vaccines'] is List) {
      vaccines =
          (data['vaccines'] as List)
              .map((v) => Vaccine.fromMap(v as Map<String, dynamic>))
              .toList();
    }

    String vaccinationStatus = _getVaccinationStatus(
      data['vaccines'] ?? [],
      dobParsed ?? DateTime(1970, 1, 1),
    );

    return Student(
      id: id,
      name: name,
      dob: dobParsed ?? DateTime(1970, 1, 1),
      daycare: daycare,
      vaccinationStatus: vaccinationStatus,
      profileImageUrl: profileImageUrl,
      parentEmail: parentEmail,
      vaccines: vaccines, // <-- Add this
    );
  }

  // Make this static since we're calling it from a factory constructor
  static String _getVaccinationStatus(
    List<dynamic> vaccines,
    DateTime dateOfBirth,
  ) {
    DateTime currentDate = DateTime.now();
    int ageInMonths =
        ((currentDate.difference(dateOfBirth).inDays) / 30)
            .floor(); // Calculate age in months

    // Check for overdue vaccines
    final overdueVaccines =
        vaccines.where((vaccine) {
          if (vaccine['administered'] == false) {
            int minAge = vaccine['minRequiredAge'];
            int? maxAge = vaccine['maxRequiredAge'];

            // If no max age is set, we only check for min age
            return ageInMonths >= minAge &&
                (maxAge == null || ageInMonths <= maxAge);
          }
          return false;
        }).toList();

    if (overdueVaccines.isNotEmpty) {
      return "overdue"; // If any vaccine is overdue
    }

    // Check for pending vaccines (vaccines the child should have but hasn't received yet)
    final pendingVaccines =
        vaccines.where((vaccine) {
          if (vaccine['administered'] == false) {
            int minAge = vaccine['minRequiredAge'];
            int? maxAge = vaccine['maxRequiredAge'];

            return ageInMonths >= minAge &&
                (maxAge == null || ageInMonths <= maxAge);
          }
          return false;
        }).toList();

    if (pendingVaccines.isNotEmpty) {
      return "pending"; // If there are vaccines pending for the child
    }

    return "upToDate"; // If all vaccines are up to date
  }
}

enum VaccineStatus {
  administered('Administered'),
  due('Due'),
  overdue('Overdue'),
  pending('Pending');

  final String value;

  const VaccineStatus(this.value);
}
