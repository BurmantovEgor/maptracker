import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../data/DTO/placeDTO.dart';
import '../data/dto/photoUpdateDTO.dart';
import '../data/dto/placeCreateDTO.dart';
import '../data/dto/placeUpdateDTO.dart';
import '../data/models/photo.dart';
import '../data/models/place.dart';

class PlaceService {
  final Dio dio;

  PlaceService()
      : dio = Dio(
          BaseOptions(
         //   baseUrl: "https://192.168.3.38:7042",
            baseUrl: "https://192.168.3.10:7042",
          ),
        ) {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  Future<List<PlaceDTO>> getUserPlaces(String userId, String jwt) async {
    try {
      print('good');
      print(userId);

      final response = await dio.get(
        '/api/places/user/${userId}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwt',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PlaceDTO.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load places');
      }
    } catch (e) {
      throw Exception('Error while fetching data');
    }
  }

  Future<List<PlaceDTO>> getPlaces(String jwt) async {
    try {
      final response = await dio.get(
        '/api/places',
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwt',
          },
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PlaceDTO.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load places');
      }
    } catch (e) {
      throw Exception('Error while fetching data');
    }
  }

  Future<void> addPlace(PlaceCreateDTO placeCreateDTO, String jwt) async {
    try {
      String latitude = placeCreateDTO.latitude.toString().replaceAll('.', ',');
      String longitude =
          placeCreateDTO.longitude.toString().replaceAll('.', ',');

      FormData formData = FormData.fromMap({
        'name': placeCreateDTO.name,
        'latitude': latitude,
        'longitude': longitude,
      });

      if (placeCreateDTO.description.trim().isNotEmpty) {
        formData.fields
            .add(MapEntry('description', placeCreateDTO.description.trim()));
      } else {
        formData.fields
            .add(const MapEntry('description', 'Описание отсутствует'));
      }

      for (int i = 0; i < placeCreateDTO.photos.length; i++) {
        var photo = placeCreateDTO.photos[i];
        MultipartFile photoFile = await MultipartFile.fromFile(
          photo.file.path,
          filename: photo.file.uri.pathSegments.last,
        );
        formData.files.add(MapEntry('photos[$i].file', photoFile));
        formData.fields.add(MapEntry('photos[$i].description', 'Нет описания'));
      }
      final response = await dio.post(
        '/api/places',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwt',
          },
        ),
      );
      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to create place');
      }
    } catch (e) {
      throw Exception('Error while sending request');
    }
  }

  Future<void> updatePlace(Place point, String jwt) async {
    try {
      PlaceUpdateDTO placeUpdateDTO = PlaceUpdateDTO.fromPointAndPhotos(point);
      for (int i = 0; i < point.photosMain.length; i++) {}
      String latitude = placeUpdateDTO.latitude.toString().replaceAll('.', ',');
      String longitude =
          placeUpdateDTO.longitude.toString().replaceAll('.', ',');

      FormData formData = FormData.fromMap({
        'name': placeUpdateDTO.name,
        'description': placeUpdateDTO.description.isEmpty
            ? 'Описание отсутствует'
            : placeUpdateDTO.description,
        'latitude': latitude,
        'longitude': longitude,
      });

      for (int i = 0; i < placeUpdateDTO.photos.length; i++) {
        var photo = placeUpdateDTO.photos[i];
        formData.fields.add(MapEntry('photos[$i].id', photo.id));
        if (photo.filePath == null) {
          MultipartFile photoFile = await MultipartFile.fromFile(
            photo.file!.path,
            filename: photo.file!.uri.pathSegments.last,
          );
          formData.files.add(MapEntry('photos[$i].file', photoFile));
        } else {
          formData.fields.add(MapEntry('photos[$i].filePath', photo.filePath!));
        }
        formData.fields.add(MapEntry('photos[$i].description', 'Нет описания'));
      }

      final response = await dio.put(
        '/api/places/${point.id}?returnUpdated=true',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwt',
          },
        ),
      );

      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to update place');
      }
    } catch (e) {
      throw Exception('Error while sending request');
    }
  }

  List<PhotoUpdateDTO> mapPhotosToUpdateDTO(List<Photo> photos) {
    return photos.map((photo) => PhotoUpdateDTO.fromPhoto(photo)).toList();
  }
}
