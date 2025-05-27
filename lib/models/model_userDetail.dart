class UserDetail {
  final String nickname;
  final String photoUrl;


  UserDetail({
    required this.nickname,
    required this.photoUrl,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      nickname: json['nickname'] as String? ?? 'null',
      photoUrl: json['photoUrl']as String? ?? 'null',
    );
  }

  Map<String, dynamic> toJson() => {
    'nickname': nickname,
    'photoUrl': photoUrl,
  };
}
