import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../cubit/admin_auth_cubit.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() != true) return;
    context.read<AdminAuthCubit>().signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientProgram),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.favorite,
                        size: 48, color: AppColors.wine),
                    const SizedBox(height: 16),
                    Text(
                      'Forever Moments',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: AppColors.roseGold,
                      ),
                    ),
                    Text(
                      'Admin console',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        letterSpacing: 3,
                        color: AppColors.champagne,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Enter your admin email'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          color: AppColors.champagne,
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Enter your password'
                          : null,
                    ),
                    const SizedBox(height: 28),
                    BlocConsumer<AdminAuthCubit, AdminAuthState>(
                      listenWhen: (p, c) =>
                          c.status == AdminAuthStatus.error &&
                          c.message != null,
                      listener: (context, state) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(state.message!),
                              backgroundColor: AppColors.wine,
                            ),
                          );
                      },
                      builder: (context, state) {
                        return FilledButton(
                          onPressed: state.isBusy ? null : _submit,
                          child: state.isBusy
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.noir,
                                  ),
                                )
                              : const Text('Sign in'),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Access is limited to authorized wedding admins.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: AppColors.champagne.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
