import 'package:boom_mobile/core/constants/api_const.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

abstract class AuthRemote {
  Future<User> loginFirebase(String email, String password);
  Future<User> registerFirebase(String email, String password);
  Future<void> syncToBackend(String uid, String email);
}

class AuthRemoteImpl implements AuthRemote {
  final FirebaseAuth _firebaseAuth;
  final Dio _dio;

  AuthRemoteImpl(this._firebaseAuth, this._dio);

  @override
  Future<User> loginFirebase(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password
      );
      return credential.user!;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<User> registerFirebase(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password
      );
      return credential.user!;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> syncToBackend(String uid, String email) async {
    try {
      await _dio.post(ApiConstants.authSync, data: {
        'uid': uid,
        'email': email,
      }, options: Options(contentType: Headers.formUrlEncodedContentType));
    } catch (e) {
      throw Exception("Backend Sync Error: $e");
    }
  }
}