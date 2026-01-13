import 'package:boom_mobile/features/boom/data/data_source/auth_remote.dart';
import 'package:boom_mobile/features/boom/domain/entities/user_entity.dart';
import 'package:boom_mobile/features/boom/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemote remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final user = await remoteDataSource.loginFirebase(email, password);
      return Right(UserEntity(uid: user.uid, email: email));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UserEntity>> register(
    String email,
    String password,
  ) async {
    try {
      final user = await remoteDataSource.registerFirebase(email, password);
      await remoteDataSource.syncToBackend(user.uid, email);
      return Right(UserEntity(uid: user.uid, email: email));
    } catch (e) {
      return Left(e.toString());
    }
  }
}
