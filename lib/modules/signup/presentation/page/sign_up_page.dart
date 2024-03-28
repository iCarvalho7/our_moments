import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/dialog_loading.dart';
import 'package:nossos_momentos/modules/core/utils/string_ext/string_ext.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/signup/presentation/bloc/sign_up_bloc.dart';

import '../../../core/presenter/widgets/background_gradient.dart';
import '../../../core/presenter/widgets/primary_app_bar.dart';
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
              const BackgroundGradient(),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: const PrimaryAppBar(title: 'Cadastrar-se'),
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      LoginTextField(
                        startIcon: Icons.alternate_email_rounded,
                        errorText: _emailErrorTxt,
                        hint: 'seu@email.com',
                        controller: _emailController,
                      ),
                      kSpacerHeight32,
                      LoginTextField(
                        startIcon: Icons.lock_person_sharp,
                        endIcon: Icons.remove_red_eye,
                        errorText: _passwordErrorTxt,
                        isPassword: true,
                        hint: '*********',
                        controller: _passwordController,
                      ),
                      kSpacerHeight32,
                      LoginTextField(
                        startIcon: Icons.lock_person_sharp,
                        endIcon: Icons.remove_red_eye,
                        hint: '*********',
                        isPassword: true,
                        errorText: _confirmPasswordErrorTxt,
                        controller: _confirmPasswordController,
                      ),
                      const Spacer(flex: 2),
                      OutlinedButton(
                        onPressed: () => _signUp(context),
                        child: const Text('Criar Conta'),
                      ),
                      const Spacer(),
                    ],
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

    if(password.length < 6) {
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(backgroundColor: Colors.white, content: Text('Usuário criado com sucesso')));
    }
  }
}
