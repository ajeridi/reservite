import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/auth_provider.dart';
import 'package:prbd_2526_a07/core/tools/validating_text_editing_controller.dart';
import 'package:prbd_2526_a07/models/user.dart';

import '../../providers/application_time_provider.dart';

class SignupMockupScreen extends ConsumerStatefulWidget {
  const SignupMockupScreen({super.key});

  @override
  ConsumerState<SignupMockupScreen> createState() => _SignupMockupScreenState();
}

class _SignupMockupScreenState extends ConsumerState<SignupMockupScreen> {
  late ValidatingTextEditingController _fullNameController;
  late ValidatingTextEditingController _emailController;
  late ValidatingTextEditingController _passwordController;
  late ValidatingTextEditingController _confirmPasswordController;
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _fullNameController = ValidatingTextEditingController(
      validator: User.validateFullName,
      asyncValidator: User.validateFullNameAvailable,
    );
    _fullNameController.onAfterValidated = () => setState(() {});

    _emailController = ValidatingTextEditingController(
      validator: User.validateEmail,
      asyncValidator: User.validateEmailAvailable,
    );
    _emailController.onAfterValidated = () => setState(() {});

    _passwordController = ValidatingTextEditingController(
      validator: User.validatePassword,
    );
    _passwordController.onAfterValidated = () => setState(() {});

    _confirmPasswordController = ValidatingTextEditingController(
      validator: (value) =>
          User.validateConfirmPassword(value, _passwordController.text),
    );
    _confirmPasswordController.onAfterValidated = () => setState(() {});
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(BuildContext context) async {
    await _fullNameController.validateAndWait();
    await _emailController.validateAndWait();
    await _passwordController.validateAndWait();
    await _confirmPasswordController.validateAndWait();

    setState(() {});

    if (_fullNameController.errorText != null || _emailController.errorText != null ||
        _passwordController.errorText != null || _confirmPasswordController.errorText != null) {
      return;
    }

    _signup(
      context,
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
    );
  }

  void _signup(
      BuildContext context, {
        required String email,
        required String password,
        required String fullName,
        String? phone,
      }) async {
    await ref.read(authProvider.notifier).signup(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
    final authState = ref.read(authProvider);

    if (!context.mounted) return;

    authState.when(
      data: (token) {
        if (token != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Compte créé et connecté !')),
          );
          Navigator.pop(context); // retour à la page de login
        }
      },
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $error')),
      ),
      loading: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simulatedTime = ref.watch(applicationTimeProvider).value;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Inscription'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {},
          ),
        ],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Tooltip(
                message:
                    'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                child: Text(
                  DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR')
                      .format(simulatedTime!),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                const Icon(Icons.person_add, size: 80, color: Colors.blue),
                const SizedBox(height: 32),
                const Text(
                  'Créez votre compte',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    errorText: _fullNameController.errorText,
                    labelText: 'Nom complet',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    errorText: _emailController.errorText,
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    errorText: _passwordController.errorText,
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    errorText: _confirmPasswordController.errorText,
                    labelText: 'Confirmer le mot de passe',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone (optionnel)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: ref.watch(authProvider).isLoading
                    ? null
                    : () => _submitForm(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('S\'inscrire'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Déjà un compte ? Se connecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
