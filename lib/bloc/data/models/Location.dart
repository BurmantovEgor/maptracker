// lib/data/models/location.dart
class Location {
  final double latitude;
  final double longitude;
  String? name;

  Location({
    required this.latitude,
    required this.longitude,
    this.name,
  });
}
class CustomPoint {
  final double latitude;
  final double longitude;
  String name;
  final bool isPointTemporay;



  CustomPoint({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.isPointTemporay,
  });

  CustomPoint copyWith({
    double? latitude,
    double? longitude,
    String? name,
    bool? isPointTemporay,
  }) {
    return CustomPoint(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      name: name ?? this.name,
      isPointTemporay: isPointTemporay ?? this.isPointTemporay,
    );
  }
}

