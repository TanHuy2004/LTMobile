import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/post.dart';

class PostService {
  static DatabaseReference get _db =>
      FirebaseDatabase.instance.ref().child('posts');

  static Future<List<Post>> fetchAllPosts() async {
    final snapshot = await _db.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((e) {
        final postData = Map<String, dynamic>.from(e.value);
        return Post.fromJson(postData, id: e.key);
      }).toList();
    }
    return [];
  }

  static Future<Post?> fetchPostDetail(String id) async {
    final snapshot = await _db.child(id).get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return Post.fromJson(data, id: id);
    }
    return null;
  }

  static Future<Post> createPost(
    String title,
    String body, {
    String? imageUrl,
    double? price, // ✅ thêm
  }) async {
    final newRef = _db.push();
    final post = Post(
      id: newRef.key!,
      title: title,
      body: body,
      imageUrl: imageUrl,
      price: price,
    );
    await newRef.set(post.toJson());
    return post;
  }

  static Future<void> updatePost(
    String id,
    String title,
    String body, {
    String? imageUrl,
    double? price, // ✅ thêm
  }) async {
    final data = {
      'title': title,
      'body': body,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (price != null) 'price': price,
    };
    await _db.child(id).update(data);
  }

  static Future<void> deletePost(String id) async {
    await _db.child(id).remove();
  }

  // ✅ Upload ảnh lên Firebase Storage (sửa cách await putFile + dùng path.basename)
  static Future<String> uploadImage(File file) async {
    const cloudName = 'dwdrwfwnd'; // 🔥 thay bằng cloud name của bạn
    const uploadPreset = 'duongtanhuy'; // 🔥 thay bằng tên preset bạn tạo

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      print('📸 Uploading ${file.path} ...');
      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(resBody);
        final imageUrl = data['secure_url'];
        print('✅ Upload thành công! URL: $imageUrl');
        return imageUrl;
      } else {
        print('❌ Upload thất bại: ${response.statusCode}');
        print(resBody);
        throw Exception('Upload thất bại');
      }
    } catch (e) {
      print('⚠️ Lỗi upload Cloudinary: $e');
      rethrow;
    }
  }
}
