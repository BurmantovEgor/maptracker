import 'dart:io';

import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../DTO/placeDTO.dart';
import '../dto/photoCreateDTO.dart';
import '../dto/placeCreateDTO.dart';
import '../models/place.dart';

class PlaceMapper {
  static Place fromPlaceRepoToPlace(PlaceDTO placeDTO) {
    return Place(
      id: placeDTO.id,
      name: placeDTO.name,
      description: placeDTO.description,
      placeLocation: Point(
        latitude: placeDTO.latitude,
        longitude: placeDTO.longitude,
      ),
      photosMain: placeDTO.photos,
      isPointTemporay: false,
      isSelected: false,
    );
  }

  static PlaceCreateDTO fromPlaceToPlaceCreateDTO(Place place) {
    final photos = place.photosMain.map((photo) {
      if (!photo.isLocal()) {
        throw Exception('Фото должно быть локальным для отправки на сервер');
      }
      return PhotoCreateDTO(
        file: File(photo.filePath),
        description: photo.description,
      );
    }).toList();

    return PlaceCreateDTO(
      name: place.name,
      description: place.description,
      latitude: place.placeLocation.latitude,
      longitude: place.placeLocation.longitude,
      photos: photos,
    );
  }

  static PlaceDTO fromPlaceToPlaceRepo(Place place) {
    return PlaceDTO(
      id: place.id,
      name: place.name,
      description: place.description,
      latitude: place.placeLocation.latitude,
      longitude: place.placeLocation.longitude,
      photos: place.photosMain,
    );
  }

  static List<Place> fromPlaceRepoListToPlaceList(
      List<PlaceDTO> placeRepoList) {
    print('пришло в маппер:{$placeRepoList}');
    final mapList = placeRepoList
        .map((placeRepo) => fromPlaceRepoToPlace(placeRepo))
        .toList();
    return mapList;
  }

  static List<PlaceDTO> fromPlaceListToPlaceRepoList(List<Place> placeList) {
    return placeList.map((place) => fromPlaceToPlaceRepo(place)).toList();
  }
}
