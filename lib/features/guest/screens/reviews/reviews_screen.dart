import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/review_model.dart';

final reviewsProvider = FutureProvider<List<ReviewModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return List.from(DummyData.reviews);
});

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Guest Reviews'),
        actions: [
          IconButton(
            icon: const Icon(Icons.rate_review_outlined),
            onPressed: () {
              // Navigate to write review
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Write review form opening...')),
              );
            },
          ),
        ],
      ),
      body: reviewsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              const Text('Failed to load reviews'),
              ElevatedButton(
                onPressed: () => ref.invalidate(reviewsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (reviews) {
          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 72, color: AppColors.mediumGrey),
                  const SizedBox(height: 16),
                  Text('No reviews yet', style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            );
          }

          final avgRating = reviews.fold<double>(0, (s, r) => s + r.rating) / reviews.length;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(reviewsProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                ),
                          ),
                          Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < avgRating.round() ? Icons.star : Icons.star_border,
                                size: 18,
                                color: AppColors.secondary,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text('${reviews.length} reviews', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [5, 4, 3, 2, 1].map((star) {
                            final count = reviews.where((r) => r.rating.round() == star).length;
                            final pct = reviews.isEmpty ? 0.0 : count / reviews.length;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Text('$star', style: Theme.of(context).textTheme.bodySmall),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      backgroundColor: AppColors.lightGrey,
                                      color: AppColors.secondary,
                                      minHeight: 6,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text('$count', style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ...reviews.map((review) => _ReviewCard(review: review)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const _WriteReviewSheet(),
          );
        },
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.primary,
        icon: const Icon(Icons.rate_review),
        label: const Text('Write Review'),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text(review.guestName[0], style: const TextStyle(color: Colors.white, fontSize: 14)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.guestName, style: Theme.of(context).textTheme.titleSmall),
                    if (review.roomName != null)
                      Text(review.roomName!, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text(review.rating.toStringAsFixed(1), style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review.comment, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _WriteReviewSheet extends StatefulWidget {
  const _WriteReviewSheet();

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  double _rating = 5;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_commentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please write a comment')));
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted!'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.mediumGrey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('Write a Review', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return IconButton(
                onPressed: () => setState(() => _rating = (i + 1).toDouble()),
                icon: Icon(
                  i < _rating ? Icons.star : Icons.star_border,
                  size: 36,
                  color: AppColors.secondary,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentCtrl,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Share your experience...'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                  : const Text('Submit Review'),
            ),
          ),
        ],
      ),
    );
  }
}
