class Cast {
  final int id;
  final String name;
  final String? profilePath;
  final String character; 

  Cast({
    required this.id,
    required this.name,
    this.profilePath,
    required this.character,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      profilePath: json['profile_path'],
      character: json['character'] ?? 'Unknown', 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_path': profilePath,
      'character': character,
    };
  }
}
