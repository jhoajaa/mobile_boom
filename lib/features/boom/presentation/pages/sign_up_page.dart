import 'package:boom_mobile/core/utils/central_notification.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/auth/auth_bloc.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/auth/auth_event.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/responsive_layout.dart';
import 'login_page.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: const _MobileSignUpView(),
        tablet: const _TabletSignUpView(),
      ),
    );
  }
}

class _MobileSignUpView extends StatefulWidget {
  const _MobileSignUpView();

  @override
  State<_MobileSignUpView> createState() => _MobileSignUpViewState();
}

class _MobileSignUpViewState extends State<_MobileSignUpView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPassController.text.trim();

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      showCentralNotification(context, "Harap isi semua kolom!", isError: true);
      return;
    }

    if (password != confirm) {
      showCentralNotification(
        context,
        "Konfirmasi password tidak cocok!",
        isError: true,
      );
      return;
    }

    context.read<AuthBloc>().add(RegisterRequested(email, password));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          showCentralNotification(context, state.message, isError: true);
        } else if (state is AuthSuccess) {
          showCentralNotification(
            context,
            "Registrasi Berhasil! Silakan Masuk.",
            isError: false,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.mainWhiteBg,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Image.asset('assets/images/logo_boom_w.png', height: 100),
                    const SizedBox(height: 40),

                    CustomTextField(
                      hint: "Email",
                      controller: _emailController,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      hint: "Kata sandi",
                      isPassword: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      hint: "Konfirmasi Kata sandi",
                      isPassword: true,
                      controller: _confirmPassController,
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (state is AuthLoading)
                            ? null
                            : _onSignUpPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainBlack,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: (state is AuthLoading)
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Daftar',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                      child: const Text(
                        "Sudah memiliki Akun? Ayo masuk Sekarang!",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TabletSignUpView extends StatefulWidget {
  const _TabletSignUpView();

  @override
  State<_TabletSignUpView> createState() => _TabletSignUpViewState();
}

class _TabletSignUpViewState extends State<_TabletSignUpView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPassController.text.trim();

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Harap isi semua kolom!")));
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi password tidak cocok!")),
      );
      return;
    }

    context.read<AuthBloc>().add(RegisterRequested(email, password));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(state.message)),
          );
        } else if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Registrasi Berhasil!"),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      },
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                color: AppColors.mainBlack,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.asset(
                          'assets/images/bg_pattern.png',
                          fit: BoxFit.cover,
                          repeat: ImageRepeat.repeat,
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Selamat datang di",
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                          const SizedBox(height: 16),
                          Image.asset(
                            'assets/images/logo_boom_w.png',
                            width: 180,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Manajemen buku Anda sekarang!",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 1,
              child: Container(
                color: AppColors.mainWhiteBg,
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Daftarkan Akun",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      CustomTextField(
                        hint: "Email",
                        controller: _emailController,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        hint: "Kata sandi",
                        isPassword: true,
                        controller: _passwordController,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        hint: "Konfirmasi Kata sandi",
                        isPassword: true,
                        controller: _confirmPassController,
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: (state is AuthLoading)
                              ? null
                              : _onSignUpPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainBlack,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: (state is AuthLoading)
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Daftar',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          ),
                          child: const Text(
                            "Sudah memiliki Akun? Ayo masuk Sekarang!",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hint,
    this.isPassword = false,
    this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _isObscure : false,
      decoration: InputDecoration(
        hintText: widget.hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black54),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isObscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.black54,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              )
            : null,
      ),
    );
  }
}
