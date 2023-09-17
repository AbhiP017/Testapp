class WebSocketResponse {
  final int id;
  final String type;
  final String messageType;
  final String message;
  final String time;
  final String name;
  final bool isOpen;
  final String mobileNo;
  final int fromId;
  final int assignedTo;
  final String locationLatitude;
  final String locationLongitude;
  final String messageId;
  final String messageStatus;
  final String fileUrl;
  final String filePath;
  final String filename;

  WebSocketResponse({
    required this.id,
    required this.type,
    required this.messageType,
    required this.message,
    required this.time,
    required this.name,
    required this.isOpen,
    required this.mobileNo,
    required this.fromId,
    required this.assignedTo,
    required this.locationLatitude,
    required this.locationLongitude,
    required this.messageId,
    required this.messageStatus,
    required this.fileUrl,
    required this.filePath,
    required this.filename,
  });

  factory WebSocketResponse.fromJson(Map<String, dynamic> json) {
    return WebSocketResponse(
      id: json['id'],
      type: json['type'],
      messageType: json['messagetype'],
      message: json['message'],
      time: json['time'],
      name: json['name'],
      isOpen: json['isopen'],
      mobileNo: json['mobileNo'],
      fromId: json['fromId'],
      assignedTo: json['assignedto'],
      locationLatitude: json['locationLatitude'],
      locationLongitude: json['locationLongitude'],
      messageId: json['messageId'],
      messageStatus: json['messageStatus'],
      fileUrl: json['fileUrl'],
      filePath: json['filePath'],
      filename: json['filename'],
    );
  }
}
