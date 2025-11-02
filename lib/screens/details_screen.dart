import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final post = ModalRoute.of(context)!.settings.arguments as Post;
    final formatter = NumberFormat("#,###", "vi_VN");
    final formattedPrice = formatter.format(post.price ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chi tiết sản phẩm",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Nếu màn hình lớn thì chia 2 cột, còn nhỏ (mobile) thì xếp dọc
            final isWide = constraints.maxWidth > 600;

            return isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Cột trái - Ảnh sản phẩm
                      Expanded(
                        flex: 5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child:
                              post.imageUrl != null && post.imageUrl!.isNotEmpty
                              ? Image.network(
                                  post.imageUrl!,
                                  height: 400,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 400,
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 100,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 24),

                      // 🔹 Cột phải - Thông tin sản phẩm
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tên sản phẩm
                            Text(
                              post.title,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Giá sản phẩm
                            Text(
                              '$formattedPrice VNĐ',
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Mô tả
                            Text(
                              post.body,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                height: 1.6,
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Chọn số lượng
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (_quantity > 1)
                                      setState(() => _quantity--);
                                  },
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    size: 28,
                                  ),
                                ),
                                Text(
                                  '$_quantity',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => setState(() => _quantity++),
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Nút thêm vào giỏ hàng
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context, {
                                    'post': post,
                                    'quantity': _quantity,
                                  });
                                },
                                icon: const Icon(
                                  Icons.add_shopping_cart,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Thêm vào giỏ hàng',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  shadowColor: Colors.blueAccent.withOpacity(
                                    0.4,
                                  ),
                                  elevation: 6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 🔹 Mobile layout (xếp dọc như cũ)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            post.imageUrl != null && post.imageUrl!.isNotEmpty
                            ? Image.network(
                                post.imageUrl!,
                                height: 250,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 250,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 80,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$formattedPrice VNĐ',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        post.body,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context, {
                            'post': post,
                            'quantity': _quantity,
                          });
                        },
                        icon: const Icon(
                          color: Colors.white,
                          Icons.add_shopping_cart,
                        ),
                        label: const Text(
                          'Thêm vào giỏ hàng',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
