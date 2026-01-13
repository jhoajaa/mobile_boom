class ApiConstants {
  static const String baseUrl = 'http://192.168.137.1:8080/api'; 
  static const String authSync = '$baseUrl/auth/sync';
  static const String books = '$baseUrl/books';
  static const String categories = '$baseUrl/categories';
  static const String updateReadingProgress = '$baseUrl/reading-progress/update';

  static get loans => null;
} 