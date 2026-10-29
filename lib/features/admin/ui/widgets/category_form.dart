import 'dart:io';
import 'package:dio/dio.dart';
import 'package:e_commerce/features/store/data/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class CategoryForm extends StatefulWidget {
  final CategoryModel? category;
  final Function(FormData data) onSubmit;

  const CategoryForm({super.key, this.category, required this.onSubmit});

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
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
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final formData = FormData.fromMap({
        'name': _nameController.text,
        if (_selectedImage != null)
          'image': await MultipartFile.fromFile(_selectedImage!.path),
      });
      widget.onSubmit(formData);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.category == null ? 'Create Category' : 'Update Category',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.muted(brightness),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : (widget.category?.image != null
                            ? DecorationImage(
                                image: NetworkImage(widget.category!.image!),
                                fit: BoxFit.cover,
                              )
                            : null),
                ),
                child: _selectedImage == null && widget.category?.image == null
                    ? const Icon(Icons.add_a_photo_outlined)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Category Name'),
              validator: (v) => v!.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: Text(widget.category == null ? 'Create' : 'Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
