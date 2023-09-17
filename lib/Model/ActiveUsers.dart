class User {
  final int userId;
  final String firstName;
  final String lastName;

  User({required this.userId, required this.firstName, required this.lastName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }
  @override
  String toString() {
    return '$firstName $lastName $userId'; // Customize the string representation
  }
}
