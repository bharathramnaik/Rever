class Stash {
  final String id;
  final String profileId;
  final String title;
  final String? description;
  final bool isPrivate;
  final String colorHex;

  const Stash({
    required this.id,
    required this.profileId,
    required this.title,
    this.description,
    this.isPrivate = false,
    this.colorHex = '#6C63FF',
  });

  factory Stash.fromJson(Map<String, dynamic> json) => Stash(
        id: json['id'] as String,
        profileId: json['profile_id'] as String,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        isPrivate: json['is_private'] as bool? ?? false,
        colorHex: json['color_hex'] as String? ?? '#6C63FF',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'profile_id': profileId,
        'title': title,
        'description': description,
        'is_private': isPrivate,
        'color_hex': colorHex,
      };
}
