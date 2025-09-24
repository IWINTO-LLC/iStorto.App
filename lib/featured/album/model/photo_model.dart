class PhotoModel {
  String? id;
  String url;
  double size;
  String? albumId;
  String? userId;
  List<String> tags;
  bool isDeleted;
  DateTime? createdAt;

  PhotoModel({
    this.id,
    required this.url,
    required this.size,
    this.albumId,
    this.userId,
    this.tags = const [],
    this.isDeleted = false,
    this.createdAt,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> data) {
    return PhotoModel(
      id: data['id'],
      url: data['url'] ?? '',
      size: (data['size'] ?? 0.0).toDouble(),
      albumId: data['album_id'],
      userId: data['user_id'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
      isDeleted: data['is_deleted'] ?? false,
      createdAt:
          data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'size': size,
      'album_id': albumId,
      'user_id': userId,
      'tags': tags,
      'is_deleted': isDeleted,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Create empty photo
  static PhotoModel empty() => PhotoModel(url: '', size: 0.0);

  PhotoModel copyWith({
    String? id,
    String? url,
    double? size,
    String? albumId,
    String? userId,
    List<String>? tags,
    bool? isDeleted,
    DateTime? createdAt,
  }) {
    return PhotoModel(
      id: id ?? this.id,
      url: url ?? this.url,
      size: size ?? this.size,
      albumId: albumId ?? this.albumId,
      userId: userId ?? this.userId,
      tags: tags ?? this.tags,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Update timestamp
  PhotoModel updateTimestamp() {
    return copyWith(createdAt: DateTime.now());
  }

  // Check if photo is valid
  bool get isValid {
    return url.isNotEmpty && size > 0 && albumId != null && albumId!.isNotEmpty;
  }

  // Check if photo is active
  bool get isActive {
    return !isDeleted;
  }

  // Get size in MB
  double get sizeInMB {
    return size;
  }

  // Get size in KB
  double get sizeInKB {
    return size * 1024;
  }

  // Get size in bytes
  int get sizeInBytes {
    return (size * 1024 * 1024).round();
  }

  @override
  String toString() {
    return 'PhotoModel(id: $id, url: $url, size: $size)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhotoModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
