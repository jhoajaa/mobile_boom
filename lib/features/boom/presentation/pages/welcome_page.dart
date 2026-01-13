import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'login_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBlack,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/images/bg_pattern.png',
                fit: BoxFit.cover, 
                width: double.infinity, 
                height: double.infinity,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          
          // --- CONTENT ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SizedBox( // Tambah SizedBox width infinity biar Column ke tengah layar
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Selamat datang di',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 20),

                  Image.asset('assets/images/logo_boom_w.png', width: 150),

                  const SizedBox(height: 20),
                  const Text(
                    'Manajemen buku Anda sekarang!',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),

                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushReplacement( // Pake pushReplacement biar ga bisa back
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.mainBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Masuk',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.chevron_right, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}