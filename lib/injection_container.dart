import 'package:boom_mobile/features/boom/data/data_source/auth_remote.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/add_book/add_book_bloc.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/book/book_bloc.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/loan/loan_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'features/boom/data/repositories/auth_repository_impl.dart';
import 'features/boom/domain/repositories/auth_repository.dart';
import 'features/boom/presentation/bloc/auth/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoC
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => BookBloc(dio: sl()));
  sl.registerFactory(() => AddBookBloc(dio: sl()));
  sl.registerFactory(() => LoanBloc(dio: sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));

  // Data Source
  sl.registerLazySingleton<AuthRemote>(() => AuthRemoteImpl(sl(), sl()));

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => Dio());
}