import 'dart:io';

class AlbumModel {
  String? id;
  String name;
  String? userId;
  int photoCount;
  double totalSize;
  String? coverUrl;
  DateTime? createdAt;
  DateTime? updatedAt;

  AlbumModel({
    this.id,
    required this.name,
    this.userId,
    this.photoCount = 0,
    this.totalSize = 0.0,
    this.coverUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> data) {
    return AlbumModel(
      id: data['id'],
      name: data['name'] ?? '',
      userId: data['user_id'],
      photoCount: data['photo_count'] ?? 0,
      totalSize: (data['total_size'] ?? 0.0).toDouble(),
      coverUrl: data['cover_url'],
      createdAt:
          data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : null,
      updatedAt:
          data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
      'photo_count': photoCount,
      'total_size': totalSize,
      'cover_url': coverUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Create empty album
  static AlbumModel empty() => AlbumModel(name: '');

  AlbumModel copyWith({
    String? id,
    String? name,
    String? userId,
    int? photoCount,
    double? totalSize,
    String? coverUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AlbumModel(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      photoCount: photoCount ?? this.photoCount,
      totalSize: totalSize ?? this.totalSize,
      coverUrl: coverUrl ?? this.coverUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Update timestamp
  AlbumModel updateTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  // Check if album is valid
  bool get isValid {
    return name.isNotEmpty && userId != null && userId!.isNotEmpty;
  }

  // Get display name
  String get displayName {
    return name;
  }

  // Get size in MB
  double get sizeInMB {
    return totalSize;
  }

  // Get size in KB
  double get sizeInKB {
    return totalSize * 1024;
  }

  @override
  String toString() {
    return 'AlbumModel(id: $id, name: $name, photoCount: $photoCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlbumModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

class TempPhoto {
  final File file;
  TempPhoto({required this.file});
}
