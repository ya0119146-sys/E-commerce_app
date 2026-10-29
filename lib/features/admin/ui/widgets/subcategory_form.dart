import 'dart:io';
import 'package:dio/dio.dart';
import 'package:e_commerce/core/constants/app_colors.dart';
import 'package:e_commerce/core/constants/app_dimensions.dart';
import 'package:e_commerce/features/store/data/models/category_model.dart';
import 'package:e_commerce/features/store/data/models/sub_category_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SubcategoryForm extends StatefulWidget {
  final SubCategoryModel? subcategory;
  final List<CategoryModel> categories;
  final Function(FormData data) onSubmit;

  const SubcategoryForm({
    super.key,
    this.subcategory,
    required this.categories,
    required this.onSubmit,
  });

  @override
  State<SubcategoryForm> createState() => _SubcategoryFormState();
}

class _SubcategoryFormState extends State<SubcategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _selectedCategoryId;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subcategory?.name);
    if (widget.subcategory != null) {
      _selectedCategoryId = widget.subcategory!.categoryId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a parent category'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      final Map<String, dynamic> data = {
        'name': _nameController.text.trim(),
        'category': _selectedCategoryId,
      };

      final formData = FormData.fromMap(data);
      if (_imageFile != null) {
        formData.files.add(
          MapEntry('image', await MultipartFile.fromFile(_imageFile!.path)),
        );
      }

      widget.onSubmit(formData);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
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
                    widget.subcategory == null
                        ? 'Create Subcategory'
                        : 'Update Subcategory',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 20),
                // Subcategory Image
                const Text(
                  'Subcategory Image',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.muted(brightness),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      image: _imageFile != null
                          ? DecorationImage(
                              image: FileImage(_imageFile!),
                              fit: BoxFit.cover,
                            )
                          : (widget.subcategory?.image != null
                                ? DecorationImage(
                                    image: NetworkImage(widget.subcategory!.image!),
                                    fit: BoxFit.cover,
                                  )
                                : null),
                    ),
                    child: _imageFile == null && widget.subcategory?.image == null
                        ? const Icon(Icons.add_a_photo_outlined, size: 40)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Parent Category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: widget.categories.map((c) {
                    return DropdownMenuItem(value: c.id, child: Text(c.name));
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                  validator: (v) =>
                      v == null ? 'Parent category is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Subcategory Name',
                    prefixIcon: Icon(Icons.subtitles_outlined),
                  ),
                  validator: (v) => v!.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(widget.subcategory == null ? 'Create' : 'Update'),
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
