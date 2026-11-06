import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../state/auth_providers.dart';
import '../../widgets/kit/feedback.dart';
import '../../widgets/kit/motion.dart';

/// Sign-in, kept to one sheet.
///
/// Email is the provider that is enabled in the project today; Google is a
/// one-line addition once it's switched on in Supabase. Either way the result
/// is the same Supabase session, so nothing downstream cares which was used.
///
/// Answers true when the cook has a session by the time the sheet closes, so a
/// caller can continue the action that needed one.
Future<bool> showSignInSheet(BuildContext context) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final signedIn = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.canvas,
    builder: (_) => const _SignInSheet(),
  );
  if (signedIn == true) return true;
  // A sheet dismissed mid-submit can still have landed a session, so the
  // session is the answer, not only the pop value.
  return container.read(authServiceProvider).isSignedIn;
}

class _SignInSheet extends ConsumerStatefulWidget {
  const _SignInSheet();

  @override
  ConsumerState<_SignInSheet> createState() => _SignInSheetState();
}

class _SignInSheetState extends ConsumerState<_SignInSheet> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _busy = false;
  bool _obscure = true;
  String? _error;
  bool _creating = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordFocus.dispose();
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
      final auth = ref.watch(authServiceProvider);
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
      if (!mounted) return;
      TextInput.finishAutofillContext();
      Navigator.of(context).pop(true);
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
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          ShokuSpace.lg,
          ShokuSpace.lg,
          ShokuSpace.lg,
          // The keyboard is insets, not a sheet size: keep room for it and let
          // the form scroll the rest.
          MediaQuery.of(context).viewInsets.bottom + ShokuSpace.xl,
        ),
        child: SingleChildScrollView(
          child: AutofillGroup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShokuSheetHeader(
                  title: l10n.authSheetTitle,
                  subtitle: l10n.authSheetBody,
                  onClose: () => Navigator.of(context).pop(false),
                ),
                const SizedBox(height: ShokuSpace.lg),
                _field(
                  key: const ValueKey('auth-email'),
                  controller: _email,
                  hint: l10n.authEmail,
                  keyboard: TextInputType.emailAddress,
                  action: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
                const SizedBox(height: ShokuSpace.sm),
                _field(
                  key: const ValueKey('auth-password'),
                  controller: _password,
                  hint: l10n.authPassword,
                  focusNode: _passwordFocus,
                  action: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  obscure: _obscure,
                  onSubmitted: (_) => _submit(),
                  suffix: IconButton(
                    key: const ValueKey('auth-password-toggle'),
                    onPressed: () => setState(() => _obscure = !_obscure),
                    tooltip: _obscure
                        ? l10n.authPasswordShow
                        : l10n.authPasswordHide,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: c.inkMuted,
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: ShokuSpace.sm),
                  Text(_error!,
                      style: ShokuType.bodySmall.copyWith(color: c.danger)),
                ],
                const SizedBox(height: ShokuSpace.lg),
                ShokuPressable(
                  key: const ValueKey('auth-submit'),
                  onTap: _busy ? null : _submit,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: _busy ? null : ShokuGradients.crimsonPress,
                      color: _busy ? c.surfaceAlt : null,
                      borderRadius: BorderRadius.circular(ShokuRadius.chip),
                      border: Border.all(
                          color: c.ink, width: ShokuStroke.brutal),
                    ),
                    child: Center(
                      child: Text(
                        _busy
                            ? l10n.authWorking
                            : (_creating
                                ? l10n.authCreateAccount
                                : l10n.authSignIn),
                        style: ShokuType.title
                            .copyWith(color: c.onAccent, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: ShokuSpace.sm),
                Center(
                  child: TextButton(
                    key: const ValueKey('auth-create-toggle'),
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
          ),
        ),
      ),
    );
  }

  Widget _field({
    required Key key,
    required TextEditingController controller,
    required String hint,
    required List<String> autofillHints,
    TextInputType? keyboard,
    TextInputAction action = TextInputAction.next,
    bool obscure = false,
    FocusNode? focusNode,
    Widget? suffix,
    ValueChanged<String>? onSubmitted,
  }) {
    final c = context.colors;
    return Container(
      padding: EdgeInsets.only(
        left: ShokuSpace.md,
        right: suffix == null ? ShokuSpace.md : 6,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ShokuRadius.chip),
        border: Border.all(color: c.hairline),
      ),
      child: TextField(
        key: key,
        controller: controller,
        focusNode: focusNode,
        obscureText: obscure,
        keyboardType: keyboard,
        textInputAction: action,
        autofillHints: autofillHints,
        onSubmitted: onSubmitted,
        style: ShokuType.body.copyWith(color: c.ink),
        cursorColor: c.accent,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: ShokuType.body.copyWith(color: c.inkMuted),
          border: InputBorder.none,
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
