import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../store/data/models/category_model.dart';
import '../../../store/data/models/product_model.dart';
import '../../../store/data/models/sub_category_model.dart';
import '../../data/repos/admin_repository.dart';

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
      final discountVal =
          discountText.isNotEmpty ? (double.tryParse(discountText) ?? 0.0) : 0.0;
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
        if (_selectedSubcategoryId != null && _selectedSubcategoryId!.isNotEmpty)
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

                // Cover Image Header with Optional Remove Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cover Image'.tr(context),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (_coverImage != null ||
                        (widget.product?.cover != null && !_coverRemoved))
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _coverImage = null;
                            _coverRemoved = true;
                          });
                        },
                        child: Text(
                          'Remove'.tr(context),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.redAccent.shade200,
                          ),
                        ),
                      ),
                  ],
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
                      border: Border.all(
                        color: AppColors.border(brightness).withValues(alpha: 0.3),
                      ),
                      image: _coverImage != null
                          ? DecorationImage(
                              image: FileImage(_coverImage!),
                              fit: BoxFit.cover,
                            )
                          : ((widget.product?.cover != null && !_coverRemoved)
                              ? DecorationImage(
                                  image: NetworkImage(widget.product!.cover!),
                                  fit: BoxFit.cover,
                                )
                              : null),
                    ),
                    child: (_coverImage == null &&
                            (widget.product?.cover == null || _coverRemoved))
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_a_photo_outlined, size: 36),
                                const SizedBox(height: 6),
                                Text(
                                  'Tap to choose cover'.tr(context),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Additional Images Header & Pick Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Additional Images'.tr(context),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: _pickAdditional,
                      icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                      label: Text('Add More'.tr(context)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_additionalImages.isNotEmpty || _existingImages.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // Retained existing images with close button
                        ..._existingImages.map(
                          (url) => Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.border(brightness)
                                        .withValues(alpha: 0.3),
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(url),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () => setState(
                                    () => _existingImages.remove(url),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Newly picked images with close button
                        ..._additionalImages.map(
                          (file) => Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.border(brightness)
                                        .withValues(alpha: 0.3),
                                  ),
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
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate_outlined),
                            const SizedBox(height: 4),
                            Text(
                              'Pick multiple images'.tr(context),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Product Name'.tr(context)),
                  validator: (v) => v!.isEmpty ? 'Required'.tr(context) : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  decoration: InputDecoration(labelText: 'Description'.tr(context)),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Required'.tr(context) : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sizeController,
                  decoration: InputDecoration(
                    labelText: 'Size (e.g. S, M, L, XL, Standard)'.tr(context),
                  ),
                  validator: (v) => v!.isEmpty ? 'Size is required'.tr(context) : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(labelText: 'Price'.tr(context)),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        validator: (v) => v!.isEmpty ? 'Required'.tr(context) : null,
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent(brightness).withValues(alpha: 0.12),
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

                // Category Dropdown with Luxury Styling & Selection Checkmark (Optional)
                DropdownButtonFormField<String?>(
                  value: _selectedCategoryId,
                  dropdownColor: AppColors.card(brightness),
                  borderRadius: BorderRadius.circular(16),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.secondary(brightness),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Category (Optional)'.tr(context),
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'None (Optional)'.tr(context),
                            style: TextStyle(
                              fontWeight: _selectedCategoryId == null
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _selectedCategoryId == null
                                  ? AppColors.secondary(brightness)
                                  : AppColors.foreground(brightness)
                                      .withValues(alpha: 0.6),
                            ),
                          ),
                          if (_selectedCategoryId == null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: AppColors.secondary(brightness),
                            ),
                          ],
                        ],
                      ),
                    ),
                    ...widget.categories.map((c) {
                      final isSelected = c.id == _selectedCategoryId;
                      return DropdownMenuItem<String?>(
                        value: c.id,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              c.name,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.secondary(brightness)
                                    : AppColors.foreground(brightness),
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 12),
                              Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: AppColors.secondary(brightness),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (v) {
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
                ),
                const SizedBox(height: 12),

                // Subcategory Dropdown with Luxury Styling & Selection Checkmark (Optional)
                Builder(
                  builder: (context) {
                    final filteredSubcats = _selectedCategoryId == null
                        ? _subcategoriesList
                        : _subcategoriesList
                            .where((s) =>
                                s.categoryId.isEmpty ||
                                s.categoryId == _selectedCategoryId)
                            .toList();
                    final subcatsToShow = filteredSubcats.isNotEmpty
                        ? filteredSubcats
                        : _subcategoriesList;

                    // Ensure _selectedSubcategoryId is actually present in subcatsToShow
                    final currentValue = subcatsToShow.any((s) => s.id == _selectedSubcategoryId)
                        ? _selectedSubcategoryId
                        : null;

                    return DropdownButtonFormField<String?>(
                      value: currentValue,
                      dropdownColor: AppColors.card(brightness),
                      borderRadius: BorderRadius.circular(16),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.secondary(brightness),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Subcategory (Optional)'.tr(context),
                        prefixIcon: const Icon(Icons.account_tree_outlined),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'None (Optional)'.tr(context),
                                style: TextStyle(
                                  fontWeight: currentValue == null
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: currentValue == null
                                      ? AppColors.secondary(brightness)
                                      : AppColors.foreground(brightness)
                                          .withValues(alpha: 0.6),
                                ),
                              ),
                              if (currentValue == null) ...[
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 18,
                                  color: AppColors.secondary(brightness),
                                ),
                              ],
                            ],
                          ),
                        ),
                        ...subcatsToShow.map((s) {
                          final isSelected = s.id == currentValue;
                          return DropdownMenuItem<String?>(
                            value: s.id,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  s.name,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.secondary(brightness)
                                        : AppColors.foreground(brightness),
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 18,
                                    color: AppColors.secondary(brightness),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: (v) =>
                          setState(() => _selectedSubcategoryId = v),
                    );
                  },
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
