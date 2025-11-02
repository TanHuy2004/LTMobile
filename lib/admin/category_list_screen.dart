import 'package:flutter/material.dart';
import '../models/post.dart';
import '../service/api_service.dart';
import '../admin/post_form_screen.dart';
import '../admin/post_detail_screen.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {"name": "iPhone", "color": Colors.blueGrey},
    {"name": "OPPO", "color": Colors.green},
    {"name": "Samsung", "color": Colors.lightBlue},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Danh mục",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        foregroundColor: Colors.black,
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 0, 234, 255),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text(
                category['name'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PostListByCategoryScreen(category: category['name']),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class PostListByCategoryScreen extends StatefulWidget {
  final String category;
  const PostListByCategoryScreen({super.key, required this.category});

  @override
  State<PostListByCategoryScreen> createState() =>
      _PostListByCategoryScreenState();
}

class _PostListByCategoryScreenState extends State<PostListByCategoryScreen> {
  late Future<List<Post>> _futurePosts;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    setState(() {
      _futurePosts = PostService.fetchAllPosts();
    });
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await PostService.deletePost(id);
        _showMessage('Xóa thành công');
        _loadPosts();
      } catch (e) {
        _showMessage('Lỗi: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh mục: ${widget.category}"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostFormScreen()),
          );
          if (result == true) _loadPosts();
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Post>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final posts = snapshot.data ?? [];
          final filtered = posts
              .where(
                (p) => p.title.toLowerCase().contains(
                  widget.category.toLowerCase(),
                ),
              )
              .toList();

          if (filtered.isEmpty) {
            return Center(
              child: Text(
                'Không có sản phẩm nào thuộc danh mục ${widget.category}.',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadPosts(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final p = filtered[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  elevation: 3,
                  child: ListTile(
                    title: Text(p.title, style: const TextStyle(fontSize: 20)),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailScreen(postId: p.id),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(p.id),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
