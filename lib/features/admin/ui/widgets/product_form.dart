import 'dart:io';
import 'package:dio/dio.dart';
import 'package:e_commerce/core/constants/app_colors.dart';
import 'package:e_commerce/core/constants/app_dimensions.dart';
import 'package:e_commerce/features/store/data/models/category_model.dart';
import 'package:e_commerce/features/store/data/models/product_model.dart';
import 'package:e_commerce/features/store/data/models/sub_category_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductForm extends StatefulWidget {
  final ProductModel? product;
  final List<CategoryModel> categories;
  final List<SubCategoryModel> subcategories;
  final Function(FormData data) onSubmit;

  const ProductForm({
    super.key,
    this.product,
    required this.categories,
    required this.subcategories,
    required this.onSubmit,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _qtyController;
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  File? _coverImage;
  final List<File> _additionalImages = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
    _descController = TextEditingController(text: widget.product?.description);
    _priceController = TextEditingController(
      text: widget.product?.price.toString(),
    );
    _qtyController = TextEditingController(
      text: widget.product?.quantity.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _coverImage = File(pickedFile.path));
    }
  }

  Future<void> _pickAdditional() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(
        () => _additionalImages.addAll(pickedFiles.map((e) => File(e.path))),
      );
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> data = {
        'name': _nameController.text,
        'description': _descController.text,
        'price': double.parse(_priceController.text),
        'quantity': int.parse(_qtyController.text),
        if (_selectedCategoryId != null) 'category': _selectedCategoryId,
        if (_selectedSubcategoryId != null)
          'subcategory': _selectedSubcategoryId,
      };

      final formData = FormData.fromMap(data);
      if (_coverImage != null) {
        formData.files.add(
          MapEntry('cover', await MultipartFile.fromFile(_coverImage!.path)),
        );
      }
      for (var file in _additionalImages) {
        formData.files.add(
          MapEntry('images', await MultipartFile.fromFile(file.path)),
        );
      }

      widget.onSubmit(formData);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    widget.product == null
                        ? 'Create Product'
                        : 'Update Product',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 20),
                // Cover Image
                const Text(
                  'Cover Image',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickCover,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.muted(brightness),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      image: _coverImage != null
                          ? DecorationImage(
                              image: FileImage(_coverImage!),
                              fit: BoxFit.cover,
                            )
                          : (widget.product?.cover != null
                                ? DecorationImage(
                                    image: NetworkImage(widget.product!.cover!),
                                    fit: BoxFit.cover,
                                  )
                                : null),
                    ),
                    child: _coverImage == null && widget.product?.cover == null
                        ? const Icon(Icons.add_a_photo_outlined, size: 40)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                // Additional Images
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Additional Images',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: _pickAdditional,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('Add More'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_additionalImages.isNotEmpty ||
                    (widget.product?.images != null &&
                        widget.product!.images.isNotEmpty))
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ..._additionalImages.map(
                          (file) => Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: FileImage(file),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () => setState(
                                    () => _additionalImages.remove(file),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.product?.images != null)
                          ...widget.product!.images.map(
                            (url) => Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(url),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _pickAdditional,
                    child: Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.muted(brightness),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd,
                        ),
                        border: Border.all(
                          color: AppColors.border(
                            brightness,
                          ).withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined),
                            Text(
                              'Pick multiple images',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _qtyController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: widget.categories
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedSubcategoryId,
                  decoration: const InputDecoration(labelText: 'Subcategory'),
                  items: widget.subcategories
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedSubcategoryId = v),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(widget.product == null ? 'Create' : 'Update'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
