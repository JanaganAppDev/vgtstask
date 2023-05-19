class GitHubRepository {
  final String name;
  final String description;

  GitHubRepository({
    required this.name,
    required this.description,
  });

  factory GitHubRepository.fromJson(Map<String, dynamic> json) {
    return GitHubRepository(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}