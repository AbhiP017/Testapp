class QuickReply {
  final int id;
  final String name;
  final String description;

  QuickReply({
    required this.id,
    required this.name,
    required this.description,
  });

  factory QuickReply.fromJson(Map<String, dynamic> json) {
    return QuickReply(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}
