class ParentModel {
  final String uid;
  final String name;
  final String email;
  final String deviceToken;

  ParentModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.deviceToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'deviceToken': deviceToken,
    };
  }
}
