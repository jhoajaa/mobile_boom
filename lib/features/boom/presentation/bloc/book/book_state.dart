import 'package:equatable/equatable.dart';
// Pastikan path import ini sesuai dengan lokasi model kamu
import '../../../data/models/book_model.dart'; 

sealed class BookState extends Equatable {
  const BookState();
  
  @override
  List<Object> get props => [];
}

final class BookInitial extends BookState {}

final class BookLoading extends BookState {}

final class BookLoaded extends BookState {
  final List<BookModel> books;

  const BookLoaded(this.books);

  @override
  List<Object> get props => [books];
}

final class BookError extends BookState {
  final String message;

  const BookError(this.message);

  @override
  List<Object> get props => [message];
}