import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../store/data/models/category_model.dart';
import '../../../store/data/models/product_model.dart';
import '../../../store/data/models/sub_category_model.dart';
import '../../data/repos/admin_repository.dart';
import 'product_form_sections/product_form_category_dropdowns.dart';
import 'product_form_sections/product_form_images_section.dart';

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
  late TextEditingController _discountController;
  late TextEditingController _qtyController;
  late TextEditingController _sizeController;
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  File? _coverImage;
  bool _coverRemoved = false;
  late List<String> _existingImages;
  final List<File> _additionalImages = [];
  late List<SubCategoryModel> _subcategoriesList;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
    _descController = TextEditingController(text: widget.product?.description);
    _sizeController = TextEditingController(text: widget.product?.size ?? 'M');
    _priceController = TextEditingController(
      text: widget.product?.price.toString(),
    );
    final initialDiscount = widget.product?.discountPercentage ?? 0;
    _discountController = TextEditingController(
      text: initialDiscount > 0 ? initialDiscount.toString() : '',
    );
    _qtyController = TextEditingController(
      text: widget.product?.quantity.toString(),
    );

    _existingImages = List<String>.from(widget.product?.images ?? []);
    _subcategoriesList = List<SubCategoryModel>.from(widget.subcategories);

    if (widget.product != null) {
      final pCatId = widget.product!.categoryId;
      final pCatName = widget.product!.category;
      for (final c in widget.categories) {
        if ((pCatId != null && c.id == pCatId) ||
            (pCatName != null &&
                (c.name.trim().toLowerCase() == pCatName.trim().toLowerCase() ||
                    c.id == pCatName))) {
          _selectedCategoryId = c.id;
          break;
        }
      }

      _matchSubcategory();
    }

    if (_subcategoriesList.isEmpty) {
      _loadSubcategories();
    }
  }

  void _matchSubcategory() {
    final pSubId = widget.product?.subcategoryId;
    final pSubName = widget.product?.subcategory;
    for (final s in _subcategoriesList) {
      if ((pSubId != null && s.id == pSubId) ||
          (pSubName != null &&
              (s.name.trim().toLowerCase() == pSubName.trim().toLowerCase() ||
                  s.id == pSubName))) {
        _selectedSubcategoryId = s.id;
        break;
      }
    }
  }

  Future<void> _loadSubcategories() async {
    try {
      final subcats = await getIt<AdminRepository>().getAllSubcategories();
      if (!mounted) return;
      setState(() {
        _subcategoriesList = subcats;
        if (_selectedSubcategoryId == null && widget.product != null) {
          _matchSubcategory();
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
        _coverRemoved = false;
      });
    }
  }

  Future<void> _pickAdditional() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (!mounted) return;
    if (pickedFiles.isNotEmpty) {
      setState(
        () => _additionalImages.addAll(pickedFiles.map((e) => File(e.path))),
      );
    }
  }

  String? _calcDiscountPreview() {
    final p = double.tryParse(_priceController.text.trim());
    final d = double.tryParse(_discountController.text.trim());
    if (p != null && d != null && d > 0 && d < 100) {
      final after = p * (1 - d / 100);
      return '${'Price after discount'.tr(context)}: \$${after.toStringAsFixed(2)}';
    }
    return null;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final discountText = _discountController.text.trim();
      final discountVal = discountText.isNotEmpty
          ? (double.tryParse(discountText) ?? 0.0)
          : 0.0;
      final Map<String, dynamic> data = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'size': _sizeController.text.trim().isNotEmpty
            ? _sizeController.text.trim()
            : 'M',
        'price': double.parse(_priceController.text),
        'discount': discountVal,
        'quantity': int.parse(_qtyController.text),
        if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty)
          'category': _selectedCategoryId
        else if (widget.product != null)
          'category': '',
        if (_selectedSubcategoryId != null &&
            _selectedSubcategoryId!.isNotEmpty)
          'subcategory': _selectedSubcategoryId
        else if (widget.product != null)
          'subcategory': '',
      };

      final formData = FormData.fromMap(data);

      // Handle cover:
      if (_coverImage != null) {
        formData.files.add(
          MapEntry('cover', await MultipartFile.fromFile(_coverImage!.path)),
        );
      } else if (widget.product?.cover != null && !_coverRemoved) {
        formData.fields.add(MapEntry('cover', widget.product!.cover!));
      } else if (_coverRemoved) {
        formData.fields.add(const MapEntry('cover', ''));
      }

      // Handle additional images:
      for (final url in _existingImages) {
        formData.fields.add(MapEntry('images', url));
      }
      for (var file in _additionalImages) {
        formData.files.add(
          MapEntry('images', await MultipartFile.fromFile(file.path)),
        );
      }
      if (widget.product != null &&
          widget.product!.images.isNotEmpty &&
          _existingImages.isEmpty &&
          _additionalImages.isEmpty) {
        formData.fields.add(const MapEntry('images', ''));
      }

      widget.onSubmit(formData);
      if (mounted) Navigator.pop(context);
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
                        ? 'Create Product'.tr(context)
                        : 'Update Product'.tr(context),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 20),

                ProductFormImagesSection(
                  coverImage: _coverImage,
                  existingCoverUrl: widget.product?.cover,
                  coverRemoved: _coverRemoved,
                  existingImages: _existingImages,
                  additionalImages: _additionalImages,
                  onPickCover: _pickCover,
                  onRemoveCover: () {
                    setState(() {
                      _coverImage = null;
                      _coverRemoved = true;
                    });
                  },
                  onPickAdditional: _pickAdditional,
                  onRemoveExistingImage: (url) =>
                      setState(() => _existingImages.remove(url)),
                  onRemoveAdditionalImage: (file) =>
                      setState(() => _additionalImages.remove(file)),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name'.tr(context),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required'.tr(context) : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  decoration: InputDecoration(
                    labelText: 'Description'.tr(context),
                  ),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Required'.tr(context) : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sizeController,
                  decoration: InputDecoration(
                    labelText: 'Size (e.g. S, M, L, XL, Standard)'.tr(context),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'Size is required'.tr(context) : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Price'.tr(context),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        validator: (v) =>
                            v!.isEmpty ? 'Required'.tr(context) : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _discountController,
                        decoration: InputDecoration(
                          labelText: 'Discount (%)'.tr(context),
                          hintText: '0 - 99',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          if (v != null && v.trim().isNotEmpty) {
                            final n = double.tryParse(v.trim());
                            if (n == null || n < 0 || n >= 100) {
                              return '0-99'.tr(context);
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                if (_calcDiscountPreview() != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent(
                          brightness,
                        ).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_offer_outlined,
                            size: 16,
                            color: AppColors.accent(brightness),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _calcDiscountPreview()!,
                            style: TextStyle(
                              color: AppColors.accent(brightness),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _qtyController,
                  decoration: InputDecoration(
                    labelText: 'Quantity'.tr(context),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required'.tr(context) : null,
                ),
                const SizedBox(height: 12),

                ProductFormCategoryDropdowns(
                  categories: widget.categories,
                  subcategories: _subcategoriesList,
                  selectedCategoryId: _selectedCategoryId,
                  selectedSubcategoryId: _selectedSubcategoryId,
                  onCategoryChanged: (v) {
                    setState(() {
                      _selectedCategoryId = v;
                      if (v == null) {
                        _selectedSubcategoryId = null;
                      } else if (_selectedSubcategoryId != null) {
                        final sub = _subcategoriesList.firstWhere(
                          (s) => s.id == _selectedSubcategoryId,
                          orElse: () => const SubCategoryModel(
                            id: '',
                            name: '',
                            categoryId: '',
                            categoryName: '',
                          ),
                        );
                        if (sub.categoryId.isNotEmpty && sub.categoryId != v) {
                          _selectedSubcategoryId = null;
                        }
                      }
                    });
                  },
                  onSubcategoryChanged: (v) =>
                      setState(() => _selectedSubcategoryId = v),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(
                      widget.product == null
                          ? 'Create'.tr(context)
                          : 'Update'.tr(context),
                    ),
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
