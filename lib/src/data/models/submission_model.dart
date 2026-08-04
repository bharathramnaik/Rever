class SubmissionModel {
  final String id;
  final String profileId;
  final String title;
  final String body;
  final String status; // pending | approved | rejected
  final DateTime createdAt;
  final DateTime? approvedAt;

  const SubmissionModel({
    required this.id,
    required this.profileId,
    required this.title,
    required this.body,
    required this.status,
    required this.createdAt,
    this.approvedAt,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) =>
      SubmissionModel(
        id: json['id'] as String,
        profileId: json['profile_id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        status: json['status'] as String? ?? 'pending',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
        approvedAt: json['approved_at'] != null
            ? DateTime.tryParse(json['approved_at'] as String)
            : null,
      );

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
}
