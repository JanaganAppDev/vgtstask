class Branch {
  final String name;

  Branch({
    required this.name,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      name: json['name'] ?? '',
    );
  }
}