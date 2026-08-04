class BookAccessModel {
  final String profileId;
  final String sourceId;
  final String status; // requested | granted | denied
  final DateTime createdAt;

  const BookAccessModel({
    required this.profileId,
    required this.sourceId,
    required this.status,
    required this.createdAt,
  });

  factory BookAccessModel.fromJson(Map<String, dynamic> json) =>
      BookAccessModel(
        profileId: json['profile_id'] as String,
        sourceId: json['source_id'] as String,
        status: json['status'] as String? ?? 'requested',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  bool get isGranted => status == 'granted';
  bool get isRequested => status == 'requested';

  /// Counts toward the 3-book access cap.
  bool get countsTowardCap => isGranted || isRequested;
}
