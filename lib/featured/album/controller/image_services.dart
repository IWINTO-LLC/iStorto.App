import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static Future<ImageData?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    final fileSize = await pickedFile.length(); // حساب الحجم بالميغابايت
    final url = "YOUR_STORAGE_UPLOAD_URL_HERE"; // يجب تنفيذ رفع الصورة إلى التخزين السحابي

    return ImageData(url: url, size: fileSize / (1024 * 1024));
  }
}

class ImageData {
  final String url;
  final double size;

  ImageData({required this.url, required this.size});
}
