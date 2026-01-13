import 'package:boom_mobile/features/boom/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<String, UserEntity>> login(String email, String password);
  Future<Either<String, UserEntity>> register(String email, String password);
}
