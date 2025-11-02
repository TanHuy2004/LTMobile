class Post {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final double? price; // 💰 thêm trường giá

  const Post({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.price,
  });

  factory Post.fromJson(Map<String, dynamic> json, {String? id}) {
    return Post(
      id: id ?? json['id'] ?? '',
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      imageUrl: json['imageUrl']?.toString(),
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'imageUrl': imageUrl,
    'price': price,
  };
}
