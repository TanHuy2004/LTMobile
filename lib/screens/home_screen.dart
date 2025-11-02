import 'package:flutter/material.dart';
import '../models/post.dart';
import '../service/api_service.dart';
import 'account_screen.dart';
import 'cart_screen.dart';
import 'details_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _selectedCategory = 'Tất cả';
  String _searchQuery = '';
  List<Post> _allPosts = [];
  List<Post> _cartItems = [];
  bool _isLoading = true;

  final _categories = [
    'Tất cả',
    'iPhone',
    'Samsung',
    'OPPO',
    'Xiaomi',
    'Realme',
  ];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    final posts = await PostService.fetchAllPosts();
    setState(() {
      _allPosts = posts;
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  void _filterCategory(String category) =>
      setState(() => _selectedCategory = category);

  void _addToCart(Post post) {
    final existingItem = _cartItems.firstWhere(
      (item) => item.id == post.id,
      orElse: () => Post(id: "not_found", title: '', body: '', price: 0),
    );

    setState(() {
      if (existingItem.id != "not_found") {
        // Nếu sản phẩm đã có trong giỏ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${post.title} đã có trong giỏ hàng!'),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        // Thêm mới sản phẩm vào giỏ
        _cartItems.add(post);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${post.title} đã được thêm vào giỏ hàng!'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  List<Post> _getFilteredPosts() {
    List<Post> filtered = _allPosts;
    if (_selectedCategory != 'Tất cả') {
      filtered = filtered
          .where(
            (post) => post.title.toLowerCase().contains(
              _selectedCategory.toLowerCase(),
            ),
          )
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (post) =>
                post.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    return filtered;
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: '🔍 Tìm kiếm sản phẩm...',
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => _filterCategory(category),
              selectedColor: Colors.blueAccent,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredPosts = _getFilteredPosts();
    if (filteredPosts.isEmpty) {
      return const Center(child: Text("Không tìm thấy sản phẩm nào."));
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: filteredPosts.length,
        itemBuilder: (context, index) {
          final post = filteredPosts[index];
          return GestureDetector(
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                '/details',
                arguments: post,
              );
              if (result != null && result is Map && result['post'] != null) {
                final selectedPost = result['post'] as Post;
                final quantity = result['quantity'] as int? ?? 1;
                for (int i = 0; i < quantity; i++) {
                  _addToCart(selectedPost);
                }
              }
            },

            child: Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🖼 Hình sản phẩm
                  Expanded(
                    flex: 6,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.grey[100]),
                      child: post.imageUrl != null && post.imageUrl!.isNotEmpty
                          ? Image.network(
                              post.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 64),
                            )
                          : const Icon(Icons.image_not_supported, size: 64),
                    ),
                  ),

                  // 📄 Tên sản phẩm
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Text(
                      post.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  // 💰 Giá + 🛒 Icon giỏ hàng (chung 1 hàng)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 💵 Giá tiền
                        Expanded(
                          child: Text(
                            post.price != null
                                ? '${NumberFormat("#,###", "vi_VN").format(post.price)} VND'
                                : 'Liên hệ',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 4),

                        // 🛒 Nút thêm giỏ hàng
                        InkWell(
                          onTap: () => _addToCart(post),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ["Cửa hàng điện thoại", "Giỏ hàng", "Tài khoản"];

    Widget body;
    if (_selectedIndex == 0) {
      body = Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 6),
          _buildCategoryBar(),
          Expanded(child: _buildHomeContent()),
        ],
      );
    } else if (_selectedIndex == 1) {
      body = CartScreen(
        cartItems: _cartItems,
        onRemoveItem: (item) {
          setState(() => _cartItems.remove(item));
        },
      );
    } else {
      body = const AccountScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (_selectedIndex == 0)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => setState(() => _selectedIndex = 1),
                ),
                if (_cartItems.isNotEmpty)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _cartItems.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Giỏ hàng",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Tài khoản"),
        ],
      ),
    );
  }
}
