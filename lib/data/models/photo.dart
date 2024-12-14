class Photo {
  final String id;
  final String? description;
  final String filePath;

  Photo({
    required this.id,
    this.description = "No description",
    required this.filePath,
  });

  bool isLocal() {
    return !filePath
        .startsWith('http');
  }

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      description: json['description'],
      filePath: json['filePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'filePath': filePath,
    };
  }
}
