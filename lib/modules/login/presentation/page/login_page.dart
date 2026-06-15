import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/background_gradient.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/dialog_loading.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_button.dart';
import 'package:nossos_momentos/modules/core/utils/string_ext/string_ext.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';

import '../../../core/presenter/routes.dart';
import '../bloc/login_bloc.dart';
import '../widget/login_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userNameTextController = TextEditingController();

  String get username => _userNameTextController.text;
  String? _usernameErrorText;

  final _passwordTextController = TextEditingController();

  String get password => _passwordTextController.text;
  String? _passwordErrorText;

  bool get hasError => _usernameErrorText != null || _passwordErrorText != null;

  @override
  void initState() {
    super.initState();
    _passwordTextController.addListener(() {
      setState(() {
        _usernameErrorText = null;
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
      create: (context) => getIt<LoginBloc>()..add(LoginEventValidateUser()),
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: _listerStateChanges,
        builder: (context, state) {
          final palette = context.palette;
          final textTheme = Theme.of(context).textTheme;
          return Scaffold(
            body: Stack(
              children: [
                const Positioned.fill(child: BackgroundGradient()),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _BrandMark(),
                            kSpacerHeight24,
                            Text(
                              'Nossos\nMomentos',
                              textAlign: TextAlign.center,
                              style: textTheme.displaySmall,
                            ),
                            kSpacerHeight8,
                            Text(
                              'Guarde o que importa, a dois.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
                            ),
                            kSpacerHeight32,
                            LoginTextField(
                              controller: _userNameTextController,
                              errorText: _usernameErrorText,
                              startIcon: Icons.person_outline,
                              hint: 'exemplo@email.com',
                            ),
                            kSpacerHeight16,
                            LoginTextField(
                              controller: _passwordTextController,
                              errorText: _passwordErrorText,
                              startIcon: Icons.lock_outline,
                              endIcon: Icons.remove_red_eye_outlined,
                              hint: '********',
                              isPassword: true,
                            ),
                            kSpacerHeight32,
                            PrimaryButton(
                              label: 'Entrar',
                              onPressed: () => _signIn(context),
                            ),
                            kSpacerHeight8,
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoute.signup.tag);
                              },
                              child: const Text('Criar uma conta'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
      context.read<LoginBloc>().add(LoginEventSignIn(username: username, password: password));
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

  bool get isFilled => _userNameTextController.text.isNotEmpty && _passwordTextController.text.isNotEmpty;

  void _listerStateChanges(BuildContext context, LoginState state) {
    if (state is LoginError) {
      Navigator.of(context).pop();
      _usernameErrorText = '';
      _passwordErrorText = 'Usuário/Senha não encontrados';
    }

    if (state is LoginLoading) {
      showLoading(context);
    }

    if (state is LoginSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.maybePop(context);
        Navigator.of(context).pushReplacementNamed(AppRoute.createTimeLine.tag);
      });
    }
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [palette.primary, palette.secondaryAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: palette.primary.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 40),
      ),
    );
  }
}
