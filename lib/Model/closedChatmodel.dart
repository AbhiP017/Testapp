class ClosedMessageModel {
  final int id;
  final String phoneNo;
  final String fullName;
  final DateTime time;
  final String lastMsg;
  final String messageType;
  final int assignedTo;
  final int count;

  ClosedMessageModel({
    required this.id,
    required this.phoneNo,
    required this.fullName,
    required this.time,
    required this.lastMsg,
    required this.messageType,
    required this.assignedTo,
    required this.count,
  });

  factory ClosedMessageModel.fromJson(Map<String, dynamic> json) {
    return ClosedMessageModel(
      id: json['id'],
      phoneNo: json['phoneNo'] ?? '',
      fullName: json['fullName'] ?? '',
      time: DateTime.parse(json['time']),
      lastMsg: json['lastMsg'],
      messageType: json['messagetype']?? '',
      assignedTo: json['assignedto'],
      count: json['count'],
    );
  }
}
