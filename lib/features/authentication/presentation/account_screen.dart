import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../gallery/domain/entities/gallery_key.dart';
import '../domain/entities/session_validation.dart';
import 'providers/auth_providers.dart';
import 'providers/web_login_providers.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _controller = TextEditingController();
  SessionValidation? _validation;
  bool _working = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('账户与会话')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          session.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('无法读取安全会话。'),
            data: (value) => Card(
              child: ListTile(
                leading: Icon(value.hasCredentials
                    ? Icons.verified_user_outlined
                    : Icons.person_outline),
                title: Text(value.hasCredentials ? '已保存站点凭据' : '尚未登录'),
                subtitle:
                    Text('${value.cookies.length} 个安全 Cookie，仅保存在本机加密存储。'),
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _working ? null : _webLogin,
            icon: const Icon(Icons.public),
            label: const Text('网页登录'),
          ),
          const SizedBox(height: 18),
          Text('导入 Cookie', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            minLines: 4,
            maxLines: 7,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'name=value; name2=value2',
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _working ? null : _importCookies,
            icon: const Icon(Icons.lock_outline),
            label: const Text('安全保存 Cookie'),
          ),
          const SizedBox(height: 24),
          Text('会话操作', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _working ? null : () => _validate(SiteSource.eHentai),
            icon: const Icon(Icons.health_and_safety_outlined),
            label: const Text('验证 E-Hentai 会话'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _working ? null : _refreshExHentai,
            icon: const Icon(Icons.refresh),
            label: const Text('刷新 ExHentai 会话'),
          ),
          if (_validation != null) ...[
            const SizedBox(height: 12),
            _ValidationCard(result: _validation!),
          ],
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _working
                ? null
                : () => ref.read(authRepositoryProvider).clearSession(),
            icon: const Icon(Icons.delete_outline),
            label: const Text('清除本机登录'),
          ),
          const SizedBox(height: 18),
          Text(
            '网页登录需要 iOS/Android 原生 Cookie bridge 才能安全读取 HttpOnly Cookie；当前可使用 Cookie 导入。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _webLogin() async {
    setState(() => _working = true);
    try {
      await ref.read(webLoginServiceProvider).authenticate();
      if (mounted) _show('网页登录会话已安全保存。');
    } catch (_) {
      if (mounted) _show('网页登录未完成，或未捕获有效会话。');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _importCookies() async {
    setState(() => _working = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .importCookieHeader(_controller.text);
      _controller.clear();
      if (mounted) _show('Cookie 已保存到本机安全存储。');
    } catch (_) {
      if (mounted) _show('Cookie 格式无效，未保存。');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _validate(SiteSource source) async {
    setState(() => _working = true);
    final result = await ref.read(sessionServiceProvider).validate(source);
    if (mounted)
      setState(() {
        _validation = result;
        _working = false;
      });
  }

  Future<void> _refreshExHentai() async {
    setState(() => _working = true);
    final result =
        await ref.read(sessionServiceProvider).refreshExHentaiSession();
    if (mounted)
      setState(() {
        _validation = result;
        _working = false;
      });
  }

  void _show(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));
}

class _ValidationCard extends StatelessWidget {
  const _ValidationCard({required this.result});

  final SessionValidation result;

  @override
  Widget build(BuildContext context) {
    final valid = result.status == SessionValidationStatus.valid;
    return Card(
      child: ListTile(
        leading: Icon(valid ? Icons.check_circle_outline : Icons.error_outline),
        title: Text(valid ? '会话有效' : '会话不可用'),
        subtitle: Text(result.message ?? result.source.displayName),
      ),
    );
  }
}
