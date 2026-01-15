import 'package:equatable/equatable.dart';

sealed class BookEvent extends Equatable {
  const BookEvent();

  @override
  List<Object> get props => [];
}

class GetBooksEvent extends BookEvent {}

class UpdateBookProgressEvent extends BookEvent {
  final String bookId;
  final String statusBaca;
  final int currentPage;

  const UpdateBookProgressEvent({
    required this.bookId,
    required this.statusBaca,
    required this.currentPage,
  });

  @override
  List<Object> get props => [bookId, statusBaca, currentPage];
}

class DeleteBookEvent extends BookEvent {
  final String bookId;
  const DeleteBookEvent(this.bookId);
  @override
  List<Object> get props => [bookId];
}
