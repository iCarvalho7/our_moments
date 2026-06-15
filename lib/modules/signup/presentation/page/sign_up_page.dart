import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/dialog_loading.dart';
import 'package:nossos_momentos/modules/core/utils/string_ext/string_ext.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/signup/presentation/bloc/sign_up_bloc.dart';

import '../../../core/presenter/widgets/background_gradient.dart';
import '../../../core/presenter/widgets/primary_app_bar.dart';
import '../../../core/presenter/widgets/primary_button.dart';
import '../../../login/presentation/widget/login_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  String? _emailErrorTxt;

  String get email => _emailController.text;

  final _passwordController = TextEditingController();
  String? _passwordErrorTxt;

  String get password => _passwordController.text;

  final _confirmPasswordController = TextEditingController();
  String? _confirmPasswordErrorTxt;

  String get confirmPassword => _confirmPasswordController.text;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {
        _emailErrorTxt = null;
      });
    });

    _passwordController.addListener(() {
      setState(() {
        _passwordErrorTxt = null;
        _confirmPasswordErrorTxt = null;
      });
    });

    _confirmPasswordController.addListener(() {
      setState(() {
        _confirmPasswordErrorTxt = null;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SignUpBloc>(),
      child: BlocConsumer<SignUpBloc, SignUpState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          return Stack(
            children: [
              const Positioned.fill(child: BackgroundGradient()),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: const PrimaryAppBar(title: 'Criar conta'),
                body: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Vamos começar',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            kSpacerHeight8,
                            Text(
                              'Crie sua conta para guardar os momentos.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: context.palette.onSurfaceMuted,
                                  ),
                            ),
                            kSpacerHeight32,
                            LoginTextField(
                              startIcon: Icons.alternate_email_rounded,
                              errorText: _emailErrorTxt,
                              hint: 'seu@email.com',
                              controller: _emailController,
                            ),
                            kSpacerHeight16,
                            LoginTextField(
                              startIcon: Icons.lock_outline,
                              endIcon: Icons.remove_red_eye_outlined,
                              errorText: _passwordErrorTxt,
                              isPassword: true,
                              hint: '*********',
                              controller: _passwordController,
                            ),
                            kSpacerHeight16,
                            LoginTextField(
                              startIcon: Icons.lock_outline,
                              endIcon: Icons.remove_red_eye_outlined,
                              hint: '*********',
                              isPassword: true,
                              errorText: _confirmPasswordErrorTxt,
                              controller: _confirmPasswordController,
                            ),
                            kSpacerHeight32,
                            PrimaryButton(
                              label: 'Criar conta',
                              onPressed: () => _signUp(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void _signUp(BuildContext context) {
    if (password.isEmpty) {
      _passwordErrorTxt = 'Senha está vazia';
    }

    if (password.length < 6) {
      _passwordErrorTxt = 'Senha precisa ser maior de 6 caracteres';
    }

    if (confirmPassword.isEmpty) {
      _confirmPasswordErrorTxt = 'Confirme a sua senha';
    }

    if (!email.isEmail) {
      _emailErrorTxt = 'Insira um email válido';
    }

    if (password != confirmPassword) {
      _passwordErrorTxt = '';
      _confirmPasswordErrorTxt = 'Senhas não coincidem';
    }

    if (!hasError) {
      context
          .read<SignUpBloc>()
          .add(SignUpEventCreateAccount(username: email, password: password));
    }

    setState(() {});
  }

  bool get hasError =>
      _passwordErrorTxt != null ||
      _confirmPasswordErrorTxt != null ||
      _emailErrorTxt != null;

  void _handleStateChanges(BuildContext context, SignUpState state) {
    if (state is SignUpLoading) {
      showLoading(context);
    }

    if (state is SignUpError) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Erro ao criar usuário')));
    }

    if (state is SignUpSuccess) {
      Navigator.of(context).pop();
      showSuccessSign(context);
     }
  }

  void showSuccessSign(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/login_success.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
                kSpacerHeight16,
                Text(
                  'Conta criada com sucesso!',
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetContext).textTheme.headlineSmall,
                ),
                kSpacerHeight8,
                Text(
                  'Agora é só entrar e começar a guardar seus momentos.',
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                        color: sheetContext.palette.onSurfaceMuted,
                      ),
                ),
                kSpacerHeight24,
                PrimaryButton(
                  label: 'Fazer login',
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
