class SourceModel {
  final String id;
  final String title;
  final String? url;
  final String? sourceType;
  final String? license;

  const SourceModel({
    required this.id,
    required this.title,
    this.url,
    this.sourceType,
    this.license,
  });

  factory SourceModel.fromJson(Map<String, dynamic> json) => SourceModel(
        id: json['id'] as String,
        title: json['title'] as String,
        url: json['url'] as String?,
        sourceType: json['source_type'] as String?,
        license: json['license'] as String?,
      );
}
