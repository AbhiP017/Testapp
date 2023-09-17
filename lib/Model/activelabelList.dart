class Activelabel {
  final int id;
  final String name;
 // final String description;

  Activelabel({
    required this.id,
    required this.name,
  //  required this.description,
  });

  factory Activelabel.fromJson(Map<String, dynamic> json) {
    return Activelabel(
      id: json['id'],
      name: json['name'],
     // description: json['description'],
    );
  }
}
