import 'dart:io';

import 'package:dio/dio.dart';

import '../models/photo.dart';

class PhotoUpdateDTO {
  final String id;
  final File? file;
  final String? filePath;
  final String? description;

  PhotoUpdateDTO({
    required this.id,
    this.file,
    this.filePath,
    this.description,
  });

  factory PhotoUpdateDTO.fromPhoto(Photo photo) {
    if (photo.isLocal()) {
      return PhotoUpdateDTO(
        id: photo.id,
        file: File(photo.filePath),
        description: photo.description,
      );
    } else {
      return PhotoUpdateDTO(
        id: photo.id,
        filePath: photo.filePath,
        description: photo.description,
      );
    }
  }

  Photo toPhoto() {
    return Photo(
      id: this.id!,
      description: this.description ?? "No description",
      filePath: this.filePath ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file': file != null ? MultipartFile.fromFileSync(file!.path) : null, // Если файл есть, отправляем его
      'filePath': filePath,
      'description': description,
    };
  }
}
