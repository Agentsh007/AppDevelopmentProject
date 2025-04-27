class LostItem {
  final String id;
  final String name;
  final String description;
  final String location;
  final String userEmail;
  final String imagePath;
  final bool found;

  LostItem({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.userEmail,
    required this.imagePath,
    required this.found,
  });

  factory LostItem.fromJson(Map<String, dynamic> json) {
    return LostItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      userEmail: json['userEmail'] ?? '',
      imagePath: json['imagePath'] ?? '',
      found: json['found'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'userEmail': userEmail,
      'imagePath': imagePath,
      'found': found,
    };
  }
}