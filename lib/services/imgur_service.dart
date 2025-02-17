import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImgurService {
  final String accessToken = "1b472b60da5b0879a470e5dd7d46326c7fe64f36"; // Thay Access Token của bạn

  Future<String?> uploadImage(File imageFile) async {
    final Uri url = Uri.parse("https://api.imgur.com/3/upload");

    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      var response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $accessToken", // Sử dụng Bearer Token
        },
        body: {
          "image": base64Image,
          "type": "base64",
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['data']['link']; // ✅ Trả về URL ảnh
      } else {
        print("Lỗi tải ảnh: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Lỗi: $e");
      return null;
    }
  }
}
