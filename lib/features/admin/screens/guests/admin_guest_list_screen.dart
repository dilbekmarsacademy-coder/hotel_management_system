import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/user_model.dart';

final adminGuestsProvider = FutureProvider<List<UserModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 350));
  return List.from(DummyData.guests);
});

class AdminGuestListScreen extends ConsumerStatefulWidget {
  const AdminGuestListScreen({super.key});

  @override
  ConsumerState<AdminGuestListScreen> createState() => _AdminGuestListScreenState();
}

class _AdminGuestListScreenState extends ConsumerState<AdminGuestListScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guestsAsync = ref.watch(adminGuestsProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Guest Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search guests...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _search = '');
                      })
                    : null,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: guestsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    const Text('Failed to load guests'),
                    ElevatedButton(onPressed: () => ref.invalidate(adminGuestsProvider), child: const Text('Retry')),
                  ],
                ),
              ),
              data: (guests) {
                var filtered = guests;
                if (_search.isNotEmpty) {
                  final q = _search.toLowerCase();
                  filtered = filtered.where((g) =>
                      g.fullName.toLowerCase().contains(q) ||
                      g.email.toLowerCase().contains(q) ||
                      (g.phone ?? '').contains(q)).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: AppColors.mediumGrey),
                        const SizedBox(height: 16),
                        Text('No guests found', style: Theme.of(context).textTheme.headlineSmall),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(adminGuestsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final g = filtered[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primary,
                              child: Text(g.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(g.fullName, style: Theme.of(context).textTheme.titleSmall),
                                  Text(g.email, style: Theme.of(context).textTheme.bodySmall),
                                  if (g.country != null)
                                    Text(g.country!, style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.mediumGrey),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
