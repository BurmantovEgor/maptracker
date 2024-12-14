import 'package:image_picker/image_picker.dart';

import '../models/photo.dart';

class PhotoMapper {

  static List<Photo> fromXFiles(List<XFile> files) {
    return files.map((file) {
      return Photo(
        id: '',
        description: '',
        filePath: file.path,
      );
    }).toList();
  }



}
