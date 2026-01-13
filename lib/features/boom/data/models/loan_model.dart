import 'package:equatable/equatable.dart';

class LoanModel extends Equatable {
  final String loanId;
  final String bookId;
  final String loanDate;
  final String? returnDate;
  final String? notes;
  final String bookTitle;
  final String coverUrl;
  final String borrowerName;
  final String? phoneNumber;
  final int isReturned;

  const LoanModel({
    required this.loanId,
    required this.bookId,
    required this.loanDate,
    this.returnDate,
    this.notes,
    required this.bookTitle,
    required this.coverUrl,
    required this.borrowerName,
    this.phoneNumber,
    required this.isReturned,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      loanId: json['loan_id'] ?? '',
      bookId: json['book_id'] ?? '',
      loanDate: json['loan_date'] ?? '',
      returnDate: json['return_date'],
      notes: json['notes'],
      bookTitle: json['book_title'] ?? 'Tanpa Judul',
      coverUrl: json['cover_image_url'] ?? '-',
      borrowerName: json['borrower_name'] ?? 'Peminjam',
      phoneNumber: json['phone_number'],
      isReturned: int.tryParse(json['is_returned'].toString()) ?? 0,
    );
  }

  @override
  List<Object?> get props => [loanId, bookId,returnDate, bookTitle, borrowerName];
}