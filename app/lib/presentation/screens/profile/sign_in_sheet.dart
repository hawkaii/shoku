import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../../data/services/auth_service.dart';
import '../../widgets/kit/motion.dart';

/// Sign-in, kept to one sheet.
///
/// Email is the provider that is enabled in the project today; Google is a
/// one-line addition once it's switched on in Supabase. Either way the result
/// is the same Supabase session, so nothing downstream cares which was used.
Future<void> showSignInSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.canvas,
    builder: (_) => const _SignInSheet(),
  );
}

class _SignInSheet extends ConsumerStatefulWidget {
  const _SignInSheet();

  @override
  ConsumerState<_SignInSheet> createState() => _SignInSheetState();
}

class _SignInSheetState extends ConsumerState<_SignInSheet> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;
  bool _creating = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.length < 6) {
      setState(() => _error = context.l10n.authErrorEmailPassword);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = AuthService();
      if (_creating) {
        final response = await auth.signUp(email, password);
        if (response.session == null) {
          // Email confirmation is on: the account exists but cannot sign in
          // yet. Saying so beats closing the sheet as if it worked.
          if (mounted) {
            setState(() {
              _busy = false;
              _creating = false;
              _error = context.l10n.authErrorConfirmEmail;
            });
          }
          return;
        }
      } else {
        await auth.signInWithPassword(email, password);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = _friendly(error);
        });
      }
    }
  }

  String _friendly(Object error) {
    final text = error.toString();
    if (text.contains('Invalid login credentials')) {
      return context.l10n.authErrorMismatch;
    }
    if (text.contains('Email not confirmed')) {
      return context.l10n.authErrorUnconfirmed;
    }
    if (text.contains('already registered')) {
      return context.l10n.authErrorExists;
    }
    if (text.contains('SocketException') || text.contains('network')) {
      return context.l10n.authErrorNoConnection;
    }
    return context.l10n.authErrorGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ShokuSpace.lg,
        ShokuSpace.lg,
        ShokuSpace.lg,
        MediaQuery.of(context).viewInsets.bottom + ShokuSpace.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.authSheetTitle, style: ShokuType.h2.copyWith(color: c.ink)),
          const SizedBox(height: 2),
          Text(
            l10n.authSheetBody,
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: ShokuSpace.lg),
          _field(c, _email, l10n.authEmail, keyboard: TextInputType.emailAddress),
          const SizedBox(height: ShokuSpace.sm),
          _field(c, _password, l10n.authPassword, obscure: true),
          if (_error != null) ...[
            const SizedBox(height: ShokuSpace.sm),
            Text(_error!, style: ShokuType.bodySmall.copyWith(color: c.danger)),
          ],
          const SizedBox(height: ShokuSpace.lg),
          ShokuPressable(
            onTap: _busy ? null : _submit,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: _busy ? null : ShokuGradients.crimsonPress,
                color: _busy ? c.surfaceAlt : null,
                borderRadius: BorderRadius.circular(ShokuRadius.chip),
                border: Border.all(color: c.ink, width: ShokuStroke.brutal),
              ),
              child: Center(
                child: Text(
                  _busy
                      ? l10n.authWorking
                      : (_creating
                          ? l10n.authCreateAccount
                          : l10n.authSignIn),
                  style: ShokuType.title.copyWith(color: c.onAccent, fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: ShokuSpace.sm),
          Center(
            child: TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() {
                        _creating = !_creating;
                        _error = null;
                      }),
              child: Text(
                _creating
                    ? l10n.authHaveAccount
                    : l10n.authCreateAccountLink,
                style: ShokuType.label.copyWith(color: c.inkMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    ShokuColors c,
    TextEditingController controller,
    String hint, {
    bool obscure = false,
    TextInputType? keyboard,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ShokuRadius.chip),
        border: Border.all(color: c.hairline),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        style: ShokuType.body.copyWith(color: c.ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: ShokuType.body.copyWith(color: c.inkMuted),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
