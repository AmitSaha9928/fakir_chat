import 'package:file_picker/file_picker.dart';

class MediaService {
  MediaService() {}

  Future<PlatformFile?> pickImageFromLibrary() async {
    FilePickerResult? _result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (_result != null) {
      return _result.files[0];
    }
    return null;
  }
}



class MediaServices {
  MediaServices() {}

  Future<List<PlatformFile>?> pickMultipleImagesFromLibrary() async {
    FilePickerResult? _result = await FilePicker.platform.pickFiles(
      allowMultiple: true, // Allow selecting multiple files
      type: FileType.image,
    );
    if (_result != null) {
      return _result.files;
    }
    return null;
  }
}

class DocServices {
  DocServices() {}

  Future<List<PlatformFile>?> pickMultipleFilesFromLibrary() async {
    FilePickerResult? _result = await FilePicker.platform.pickFiles(
      allowMultiple: true, // Allow selecting multiple files
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'pdf', 'doc'],
    );
    if (_result != null) {
      return _result.files;
    }
    return null;
  }
}
