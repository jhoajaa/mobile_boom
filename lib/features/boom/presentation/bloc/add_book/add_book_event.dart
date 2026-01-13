import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AddBookEvent extends Equatable {
  const AddBookEvent();
  @override
  List<Object> get props => [];
}

class ScanBookEvent extends AddBookEvent {}

class SubmitBookEvent extends AddBookEvent {
  final Map<String, dynamic> bookData;
  final File? localImage;

  const SubmitBookEvent(this.bookData, this.localImage);
}

class UpdateBookEvent extends AddBookEvent {
  final String bookId;
  final Map<String, dynamic> data;
  final File? coverImage;

  const UpdateBookEvent({
    required this.bookId,
    required this.data,
    this.coverImage,
  });

  @override
  List<Object> get props => [bookId, data, if (coverImage != null) coverImage!];
}