import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../favorites/presentation/providers/cloud_favorites_providers.dart';
import '../../domain/entities/gallery.dart';

class CloudFavoriteSheet extends ConsumerStatefulWidget {
  const CloudFavoriteSheet({required this.gallery, super.key});

  final Gallery gallery;

  @override
  ConsumerState<CloudFavoriteSheet> createState() => _CloudFavoriteSheetState();
}

class _CloudFavoriteSheetState extends ConsumerState<CloudFavoriteSheet> {
  var _category = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cloudFavoritesNotifierProvider);
    final notifier = ref.read(cloudFavoritesNotifierProvider.notifier);
    final categories = state.categories.isEmpty
        ? ref.read(cloudFavoritesRepositoryProvider).defaultCategories()
        : state.categories;
    final isFavorite = notifier.contains(widget.gallery);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('账户收藏', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _category,
            items: [
              for (final category in categories)
                DropdownMenuItem(value: category.id, child: Text(category.name)),
            ],
            onChanged: state.isLoading ? null : (value) => setState(() => _category = value ?? 0),
            decoration: const InputDecoration(labelText: '收藏夹'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: state.isLoading
                ? null
                : () async {
                    await notifier.setFavorite(
                      gallery: widget.gallery,
                      category: _category,
                      value: !isFavorite,
                    );
                    if (context.mounted) Navigator.of(context).pop();
                  },
            icon: Icon(isFavorite ? Icons.cloud_off_outlined : Icons.cloud_upload_outlined),
            label: Text(isFavorite ? '移出当前账户收藏' : '加入账户收藏'),
          ),
        ],
      ),
    );
  }
}
