class Chat {
  final String userId;
  final String receiverId;
  final String text;
  final DateTime createdAt;
  final String chatRoomId;

  Chat({
    required this.userId,
    required this.receiverId,
    required this.text,
    required this.createdAt,
    required this.chatRoomId,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      userId: json['userId'] as String? ?? 'null',
      receiverId: json['receiverId'] as String? ?? 'null',
      text: json['text'] as String? ?? 'null',
      createdAt: json['createdAt']?.toDate(),
      chatRoomId: json['chatRoomId'] as String? ?? 'null',
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'receiverId': receiverId,
    'text': text,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    'chatRoomId': chatRoomId,

  };
}
