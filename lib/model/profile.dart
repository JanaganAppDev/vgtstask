class Profile {
  final String username;
  final String img;

  Profile({
    required this.username,
    required this.img,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      username: json['login'] ?? '',
      img: json['avatar_url'] ?? '',
    );
  }
}