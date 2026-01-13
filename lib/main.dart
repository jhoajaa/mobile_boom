import 'package:boom_mobile/features/boom/presentation/bloc/book/book_bloc.dart';
import 'package:boom_mobile/features/boom/presentation/pages/login_page.dart';
import 'package:boom_mobile/features/boom/presentation/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_colors.dart';
import 'injection_container.dart' as di;
import 'features/boom/presentation/bloc/auth/auth_bloc.dart';
import 'features/boom/presentation/pages/welcome_page.dart';
import 'firebase_options.dart';
import 'package:dio/dio.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (context) => BookBloc(dio: Dio())), 
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BooM App',
        theme: ThemeData(scaffoldBackgroundColor: AppColors.mainWhiteBg),
        home: ResponsiveLayout(
          mobile: const WelcomePage(),
          tablet: const LoginPage(),
        ),
      ),
    );
  }
}