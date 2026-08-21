import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/hero_button.dart';
import '../../logic/review_cubit.dart';
import '../../logic/review_state.dart';

class AddReviewDialog extends StatefulWidget {
  final String productId;

  const AddReviewDialog({super.key, required this.productId});

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final _reviewController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double _rating = 5.0;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_reviewController.text.trim().isNotEmpty) {
      context.read<ReviewCubit>().createReview(
        _reviewController.text.trim(),
        _rating,
        widget.productId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return BlocListener<ReviewCubit, ReviewState>(
      listener: (context, state) {
        if (state is ReviewActionSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          // Refresh reviews
          context.read<ReviewCubit>().fetchProductReviews(widget.productId);
        } else if (state is ReviewError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Form(
        key: _formKey,
        child: AlertDialog(
          backgroundColor: AppColors.card(brightness),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          title: const Text('Write a Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setState(() => _rating = index + 1.0),
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: AppColors.accent(brightness),
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a review';
                  }
                  return null;
                },
                controller: _reviewController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Share your experience with this product...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            SizedBox(
              width: 120,
              child: HeroButton(
                text: 'Submit',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _onSubmit();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
