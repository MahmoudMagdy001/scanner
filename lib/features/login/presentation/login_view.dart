import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../card_scanner/card_scanner_view.dart';
import 'cubit/login_cubit.dart';
import 'cubit/login_state.dart';

class LogInView extends StatelessWidget {
  const LogInView({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => GetIt.I<LoginCubit>(),
    child: Scaffold(
      backgroundColor: colorBackground,
      body: SafeArea(
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              MagicRouter.navigateAndPopAll(const CardScannerView());
            }
          },
          builder: (context, state) {
            final cubit = LoginCubit.of(context);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: cubit.formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // ─── Logo Block ───
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: colorPrimary,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: colorPrimary.withAlpha(60),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Welcome Back',
                      style: AppTextStyles.displayLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to access the housing system',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // ─── Login Card ───
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colorBorder, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: colorPrimary.withAlpha(10),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Address',
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            hint: 'Enter your email',
                            controller: cubit.emailController,
                            prefixIcon: const Icon(
                              Icons.mail_outline_rounded,
                              size: 20,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Password',
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            hint: 'Enter your password',
                            secure: true,
                            controller: cubit.passwordController,
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              size: 20,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ─── Login Button ───
                    BlocBuilder<LoginCubit, LoginState>(
                      buildWhen: (previous, current) =>
                          previous.runtimeType != current.runtimeType,
                      builder: (context, state) => CustomButton(
                        text: state is LoginLoading ? '' : 'Sign In',
                        isLoading: state is LoginLoading,
                        isIcon: state is! LoginLoading,
                        icon: const Icon(
                          Icons.login_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPress: () => _login(context),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ),
  );

  void _login(BuildContext context) {
    final cubit = LoginCubit.of(context);
    if (cubit.formKey.currentState!.validate()) {
      cubit.login();
    }
  }
}
