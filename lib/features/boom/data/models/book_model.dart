import 'package:equatable/equatable.dart';

class BookModel extends Equatable {
  final String bookId;
  final String userId;
  final String categoryId;
  final String title;
  final String author;
  final String publisher;
  final String categoryName;
  final String coverUrl;
  final String status;
  final int totalPages;
  final int currentPage;

  const BookModel({
    required this.bookId,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.author,
    required this.publisher,
    required this.categoryName,
    required this.coverUrl,
    required this.status,
    required this.totalPages,
    required this.currentPage,
  });

  BookModel copyWith({
    String? bookId,
    String? userId,
    String? categoryId,
    String? title,
    String? author,
    String? publisher,
    String? categoryName,
    String? coverUrl,
    String? status,
    int? totalPages,
    int? currentPage,
  }) {
    return BookModel(
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      author: author ?? this.author,
      publisher: publisher ?? this.publisher,
      categoryName: categoryName ?? this.categoryName,
      coverUrl: coverUrl ?? this.coverUrl,
      status: status ?? this.status,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      bookId: map['book_id'] ?? '',
      userId: map['user_id'] ?? '',
      categoryId: map['category_id'] ?? '', 
      title: map['title'] ?? 'Tanpa Judul',
      author: map['author'] ?? 'Unknown Author',
      publisher: map['publisher'] ?? '-',
      categoryName: map['category_name'] ?? '-', 
      
      coverUrl: (map['cover_image_url'] == null || map['cover_image_url'] == '') 
          ? '-' 
          : map['cover_image_url'],
      
      status: map['status_baca'] ?? 'belum_dibaca',
      
      totalPages: int.tryParse(map['total_pages'].toString()) ?? 0,
      currentPage: int.tryParse(map['current_page'].toString()) ?? 0,
    );
  }

  factory BookModel.fromJson(Map<String, dynamic> json) => BookModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'book_id': bookId,
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'author': author,
      'publisher': publisher,
      'category_name': categoryName,
      'cover_image_url': coverUrl,
      'status_baca': status,
      'total_pages': totalPages,
      'current_page': currentPage,
    };
  }

  double get progressPercentage {
    if (totalPages == 0) return 0.0;
    double progress = currentPage / totalPages;
    return progress > 1.0 ? 1.0 : progress;
  }

  String get statusDisplay {
    switch (status) {
      case 'belum_dibaca': return 'Belum Dibaca';
      case 'sedang_dibaca': return 'Sedang Dibaca';
      case 'selesai': return 'Selesai!';
      case 'dipinjam': return 'Dipinjam';
      default: 
        return status.replaceAll('_', ' ').split(' ').map((str) => 
          str.isNotEmpty ? str[0].toUpperCase() + str.substring(1) : ''
        ).join(' ');
    }
  }

  @override
  List<Object?> get props => [
    bookId,
    userId,
    categoryId,
    title, 
    author, 
    publisher, 
    categoryName, 
    coverUrl, 
    status, 
    totalPages, 
    currentPage
  ];
}