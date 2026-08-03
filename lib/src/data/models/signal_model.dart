/// A single user action on an idea (flow.txt §3 signal list).
class SignalModel {
  final String? id;
  final String? profileId;
  final String? ideaCardId;
  final String signalType;
  final Map<String, dynamic> payload;
  final DateTime? createdAt;

  const SignalModel({
    this.id,
    this.profileId,
    this.ideaCardId,
    required this.signalType,
    this.payload = const {},
    this.createdAt,
  });

  static const allowedTypes = {
    'opened',
    'finished',
    'liked',
    'mind_blown',
    'actionable',
    'saved',
    'shared',
    'skipped',
    'returned',
    'dwelled',
    'searched',
  };

  factory SignalModel.fromJson(Map<String, dynamic> json) => SignalModel(
        id: json['id'] as String?,
        profileId: json['profile_id'] as String?,
        ideaCardId: json['idea_card_id'] as String?,
        signalType: json['signal_type'] as String,
        payload: (json['payload'] as Map<String, dynamic>?) ?? const {},
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        if (profileId != null) 'profile_id': profileId,
        if (ideaCardId != null) 'idea_card_id': ideaCardId,
        'signal_type': signalType,
        'payload': payload,
      };
}
