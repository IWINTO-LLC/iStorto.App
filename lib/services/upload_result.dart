class UploadResult {
  final String fileUrl;
  final List<String> tags;

  UploadResult({required this.fileUrl, required this.tags});

  Map<String, dynamic> toJson() {
    return {'fileUrl': fileUrl, 'tags': tags};
  }

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      fileUrl: json['fileUrl'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
