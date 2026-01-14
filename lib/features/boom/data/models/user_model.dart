class UserModel {
  final String userId;
  final String email;
  final String? fullName;

  final int totalBooks;
  final int finishedBooks;
  final int activeLoans;

  UserModel({
    required this.userId,
    required this.email,
    this.fullName,
    this.totalBooks = 0,
    this.finishedBooks = 0,
    this.activeLoans = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};

    return UserModel(
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'],

      totalBooks: int.tryParse(stats['total_books'].toString()) ?? 0,
      finishedBooks: int.tryParse(stats['finished_books'].toString()) ?? 0,
      activeLoans: int.tryParse(stats['active_loans'].toString()) ?? 0,
    );
  }
}
