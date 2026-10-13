import 'package:flutter/material.dart';
import '../network/api_client.dart';

class LoginScreen extends StatefulWidget {
  final Future<void> Function(ApiClient api, String username) onAuthenticated;
  const LoginScreen({super.key, required this.onAuthenticated});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _api = ApiClient();
  final _form = GlobalKey<FormState>();
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _registerMode = false;
  String? _error;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.black87,
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _registerMode ? 'Create Account' : 'Welcome Back',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _user,
                  style: const TextStyle(color: Colors.white),
                  decoration: _field('Username'),
                  validator: (v) =>
                      (v ?? '').length < 3 ? 'Min 3 chars' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pass,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: _field('Password'),
                  validator: (v) =>
                      (v ?? '').length < 6 ? 'Min 6 chars' : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: Text(_registerMode ? 'Register' : 'Login'),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _registerMode = !_registerMode;
                    _error = null;
                  }),
                  child: Text(
                    _registerMode
                        ? 'Have an account? Log in'
                        : 'New here? Register',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _field(String label) => InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      );

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final res = _registerMode
          ? await _api.register(_user.text.trim(), _pass.text)
          : await _api.login(_user.text.trim(), _pass.text);
      if (res['ok'] == true) {
        await widget.onAuthenticated(_api, _user.text.trim());
      } else {
        setState(() => _error = res['error'] as String? ?? 'Unknown error');
      }
    } on ApiException catch (e) {
      setState(() => _error = 'Server error ${e.status}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}