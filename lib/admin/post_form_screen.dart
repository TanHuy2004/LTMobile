import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../service/api_service.dart';

class PostFormScreen extends StatefulWidget {
  final Post? editPost;
  const PostFormScreen({super.key, this.editPost});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(); // 💰 controller giá
  bool _loading = false;

  XFile? _pickedImage;
  String? _uploadedImageUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = picked);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.editPost != null) {
      _titleCtrl.text = widget.editPost!.title;
      _bodyCtrl.text = widget.editPost!.body;
      if (widget.editPost!.price != null) {
        _priceCtrl.text = NumberFormat(
          '#,###',
          'vi_VN',
        ).format(widget.editPost!.price).replaceAll(',', '.');
      }
      _uploadedImageUrl = widget.editPost!.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _savePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      // Upload ảnh nếu có chọn mới
      if (_pickedImage != null) {
        _uploadedImageUrl = await PostService.uploadImage(
          File(_pickedImage!.path),
        );
      }

      // Xử lý giá tiền: loại dấu chấm -> chuyển sang double
      final double? price = double.tryParse(
        _priceCtrl.text.replaceAll('.', '').trim(),
      );

      if (widget.editPost == null) {
        // 👉 Tạo mới
        await PostService.createPost(
          _titleCtrl.text,
          _bodyCtrl.text,
          imageUrl: _uploadedImageUrl,
          price: price,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm sản phẩm thành công')),
        );
      } else {
        // 👉 Cập nhật
        await PostService.updatePost(
          widget.editPost!.id,
          _titleCtrl.text,
          _bodyCtrl.text,
          imageUrl: _uploadedImageUrl,
          price: price,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật sản phẩm thành công')),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Lỗi: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editPost != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🔹 Tên sản phẩm
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tên sản phẩm',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Vui lòng nhập tên sản phẩm'
                    : null,
              ),
              const SizedBox(height: 16),

              // 🔹 Mô tả sản phẩm
              TextFormField(
                controller: _bodyCtrl,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                minLines: 4,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Mô tả sản phẩm',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true, // đảm bảo label căn giữa multiline
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Vui lòng nhập mô tả' : null,
              ),
              const SizedBox(height: 16),
              // 🔹 Giá sản phẩm (tự format dấu chấm)
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá sản phẩm (VNĐ)',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final text = newValue.text.replaceAll('.', '');
                    if (text.isEmpty) return newValue;

                    final number = NumberFormat('#,###', 'vi_VN')
                        .format(int.parse(text))
                        .replaceAll(',', '.'); // 💰 dấu chấm phân cách

                    return newValue.copyWith(
                      text: number,
                      selection: TextSelection.collapsed(offset: number.length),
                    );
                  }),
                ],
                validator: (v) => v == null || v.isEmpty
                    ? 'Vui lòng nhập giá sản phẩm'
                    : null,
              ),
              const SizedBox(height: 16),

              // 🔹 Ảnh sản phẩm
              Column(
                children: [
                  if (_pickedImage != null)
                    Image.file(
                      File(_pickedImage!.path),
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  if (_pickedImage == null && _uploadedImageUrl != null)
                    Image.network(
                      _uploadedImageUrl!,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Chọn hình ảnh'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 🔹 Nút lưu
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _savePost,
                      icon: const Icon(Icons.save),
                      label: Text(isEdit ? 'Cập nhật' : 'Thêm mới'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
