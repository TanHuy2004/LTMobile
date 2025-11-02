import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';

class CartScreen extends StatefulWidget {
  final List<Post> cartItems;
  final Function(Post) onRemoveItem;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onRemoveItem,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Lưu số lượng cho từng sản phẩm
  final Map<Post, int> _quantities = {};

  @override
  @override
  void initState() {
    super.initState();

    for (var item in widget.cartItems) {
      // Nếu đã có thì cộng dồn
      if (_quantities.containsKey(item)) {
        _quantities[item] = _quantities[item]! + 1;
      } else {
        _quantities[item] = 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.cartItems;
    final formatter = NumberFormat("#,###", "vi_VN");

    // ✅ Tổng tiền
    double total = cart.fold(
      0,
      (sum, item) => sum + ((item.price ?? 0) * (_quantities[item] ?? 1)),
    );

    return Scaffold(
      body: cart.isEmpty
          ? const Center(
              child: Text("🛒 Giỏ hàng trống.", style: TextStyle(fontSize: 18)),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      final priceText = formatter.format(item.price ?? 0);
                      final qty = _quantities[item] ?? 1;
                      final subtotal = (item.price ?? 0) * qty;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Ảnh sản phẩm
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child:
                                    item.imageUrl != null &&
                                        item.imageUrl!.isNotEmpty
                                    ? Image.network(
                                        item.imageUrl!,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 70,
                                        height: 70,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 10),

                              // Tên + giá
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '$priceText VNĐ',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Thành tiền: ${formatter.format(subtotal)} VNĐ',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Nút tăng/giảm số lượng
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle,
                                      color: Colors.blueAccent,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _quantities[item] = qty + 1;
                                      });
                                    },
                                  ),
                                  Text(
                                    qty.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (qty > 1) {
                                          _quantities[item] = qty - 1;
                                        } else {
                                          widget.onRemoveItem(item);
                                          _quantities.remove(item);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Tổng cộng
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng cộng:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${formatter.format(total)} VNĐ',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Nút đặt hàng
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (cart.isEmpty) return;

                      // ✅ Giả lập hiệu ứng loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blueAccent,
                          ),
                        ),
                      );

                      await Future.delayed(const Duration(seconds: 1));
                      Navigator.pop(context); // Đóng loading

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Thanh toán thành công! Cảm ơn bạn đã mua hàng!!!',
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );

                      // ✅ Xóa giỏ hàng
                      setState(() {
                        cart.clear();
                        _quantities.clear();
                      });
                    },
                    label: const Text(
                      "Thanh toán",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
