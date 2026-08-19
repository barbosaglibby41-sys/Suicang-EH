import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../tags/presentation/providers/subscribed_tags_providers.dart';
import '../../../tags/presentation/providers/tag_translation_providers.dart';
import '../../domain/entities/gallery_tag.dart';

class TranslatedTagGroups extends ConsumerWidget {
  const TranslatedTagGroups({
    required this.tags,
    required this.onSearch,
    super.key,
  });

  final List<GalleryTag> tags;
  final ValueChanged<GalleryTag> onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = ref.watch(tagTranslationRepositoryProvider);
    final subscriptions = ref.watch(subscribedTagsProvider);
    final groups = <String, List<GalleryTag>>{};
    for (final tag in tags) {
      (groups[tag.namespace.isEmpty ? 'other' : tag.namespace] ??= []).add(tag);
    }
    final namespaces = groups.keys.toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final namespace in namespaces) ...[
          _TagNamespaceRow(
            namespace: namespace,
            tags: groups[namespace]!,
            translations: translations,
            subscribed: subscriptions.valueOrNull?.toSet() ?? const <String>{},
            onSearch: onSearch,
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _TagNamespaceRow extends ConsumerWidget {
  const _TagNamespaceRow({
    required this.namespace,
    required this.tags,
    required this.translations,
    required this.subscribed,
    required this.onSearch,
  });

  final String namespace;
  final List<GalleryTag> tags;
  final dynamic translations;
  final Set<String> subscribed;
  final ValueChanged<GalleryTag> onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 58),
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            color: _namespaceColor(namespace, scheme),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _namespaceLabel(namespace),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSecondaryContainer,
                ),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final tag in tags)
                _TagPill(
                  tag: tag,
                  translated: translations.find(tag.rawName)?.name ??
                      tag.translatedName,
                  subscribed: subscribed.contains(tag.rawName),
                  onSearch: () => onSearch(tag),
                  onSubscribe: () => ref
                      .read(subscribedTagsRepositoryProvider)
                      .toggle(tag.rawName),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _namespaceLabel(String value) => switch (value) {
        'language' => '语言',
        'parody' => '原作',
        'character' => '角色',
        'group' => '团队',
        'artist' => '作者',
        'female' => '女性',
        'male' => '男性',
        'mixed' => '混合',
        'other' => '其他',
        'reclass' => '分类',
        _ => value,
      };

  Color _namespaceColor(String value, ColorScheme scheme) => switch (value) {
        'female' => const Color(0xFFE8D9F7),
        'male' => const Color(0xFFFFDDDD),
        'mixed' => const Color(0xFFDCE7FA),
        'artist' || 'group' => const Color(0xFFD9E9DA),
        'language' => const Color(0xFFF8DCF6),
        'parody' => const Color(0xFFF7E0D0),
        _ => scheme.secondaryContainer,
      };
}

class _TagPill extends StatelessWidget {
  const _TagPill({
    required this.tag,
    required this.translated,
    required this.subscribed,
    required this.onSearch,
    required this.onSubscribe,
  });

  final GalleryTag tag;
  final String? translated;
  final bool subscribed;
  final VoidCallback onSearch;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    final label = translated?.isNotEmpty == true ? translated! : tag.rawName;
    return Semantics(
      button: true,
      label: label,
      hint: '点击搜索，长按订阅',
      child: GestureDetector(
        onLongPress: onSubscribe,
        child: ActionChip(
          avatar: subscribed
              ? const Icon(Icons.notifications_active_outlined, size: 15)
              : null,
          label: Text(label),
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
          onPressed: onSearch,
        ),
      ),
    );
  }
}
