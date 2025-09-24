// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:typed_data';

class ImageModel {
  String id;
  final String url;
  String mediaCategory;
  final String folder;
  final int? sizeByte;
  final String fileName;
  final String? fullPath;
  final String contentType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final File? file;
  final Int8List localImageToDisplay;
  ImageModel(
    this.sizeByte,
    this.file,
    this.localImageToDisplay, {
    this.id = '',
    required this.url,
    required this.mediaCategory,
    required this.folder,
    required this.fileName,
    this.fullPath,
    required this.contentType,
    this.createdAt,
    this.updatedAt,
  });
}
