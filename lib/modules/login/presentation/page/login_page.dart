import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/utils/string_ext/string_ext.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';

import '../bloc/login_bloc.dart';
import '../widget/login_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userNameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  String? _usernameErrorText;
  String? _passwordErrorText;

  String get username => _userNameTextController.text;

  String get password => _passwordTextController.text;

  bool get hasError => _usernameErrorText != null || _passwordErrorText != null;

  @override
  void initState() {
    super.initState();
    _passwordTextController.addListener(() {
      setState(() {
        _passwordErrorText = null;
      });
    });

    _userNameTextController.addListener(() {
      setState(() {
        _usernameErrorText = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginBloc>(),
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: _listerStateChanges,
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: AppColors.loginGradient,
                        stops: [0.0, 1.0],
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth > 1200 ? 500.0 : constraints.maxWidth;
                        return SizedBox(
                          width: width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Spacer(flex: 2),
                              Text(
                                'Nossos\nMomentos',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Spacer(flex: 1),
                              LoginTextField(
                                controller: _userNameTextController,
                                errorText: _usernameErrorText,
                                startIcon: Icons.person,
                                hint: 'exemplo@email.com',
                              ),
                              kSpacerHeight16,
                              LoginTextField(
                                controller: _passwordTextController,
                                errorText: _passwordErrorText,
                                startIcon: Icons.lock,
                                endIcon: Icons.remove_red_eye,
                                hint: '********',
                                isPassword: true,
                              ),
                              kSpacerHeight32,
                              const Spacer(flex: 3),
                              Material(
                                elevation: 4,
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                                child: OutlinedButton(
                                  onPressed: () => _signIn(context),
                                  child: const Text('Login'),
                                ),
                              ),
                              kSpacerHeight32,
                              TextButton(
                                onPressed: () {},
                                child: const Text('Criar uma conta'),
                              ),
                              const Spacer(flex: 1),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _signIn(BuildContext context) {
    _validateUsername();
    _validatePassword();

    setState(() {});
    if (!hasError) {
      context
          .read<LoginBloc>()
          .add(LoginEventSignIn(username: username, password: password));
    }
  }

  void _validatePassword() {
    if (password.isEmpty) {
      _passwordErrorText = 'Preencha a senha';
    }
  }

  void _validateUsername() {
    if (username.isEmpty) {
      _usernameErrorText = 'Preencha o email';
    }

    if (!username.isEmail) {
      _usernameErrorText = 'Insira um email válido';
    }
  }

  bool get isFilled =>
      _userNameTextController.text.isNotEmpty &&
      _passwordTextController.text.isNotEmpty;

  void _listerStateChanges(BuildContext context, LoginState state) {
    if (state is LoginError) {
      Navigator.of(context).pop();
      _usernameErrorText = '';
      _passwordErrorText = 'Usuário/Senha não encontrados';
    }

    if (state is LoginLoading) {
      var backgroundColor = Colors.transparent;

      showDialog(
        context: context,
        barrierColor: backgroundColor,
        builder: (_) {
          return AlertDialog(
            backgroundColor: backgroundColor,
            shadowColor: backgroundColor,
            surfaceTintColor: backgroundColor,
            content: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    }

    if (state is LoginSuccess) {
      Navigator.of(context).pop();
    }
  }
}
