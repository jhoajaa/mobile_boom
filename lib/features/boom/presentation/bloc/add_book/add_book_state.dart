import 'dart:io';
import 'package:boom_mobile/features/boom/data/models/category_model.dart';
import 'package:equatable/equatable.dart';

abstract class AddBookState extends Equatable {
  const AddBookState();
  @override
  List<Object> get props => [];
}

class AddBookInitial extends AddBookState {}

class AddBookLoading extends AddBookState {}

class AddBookReady extends AddBookState {
  final List<CategoryModel> categories;
  const AddBookReady(this.categories);
  @override
  List<Object> get props => [categories];
}

class AddBookScanned extends AddBookState {
  final Map<String, dynamic> data;
  final File localImage;
  final List<CategoryModel> categories;
  final String? predictedCategoryId;
  final String? message;

  const AddBookScanned(
    this.data,
    this.localImage,
    this.categories,
    this.predictedCategoryId, {
    this.message,
  });

  @override
  List<Object> get props => [
    data,
    localImage,
    categories,
    predictedCategoryId ?? '',
    message ?? '',
  ];
}

class AddBookSuccess extends AddBookState {}

class AddBookFailure extends AddBookState {
  final String message;
  const AddBookFailure(this.message);
  @override
  List<Object> get props => [message];
}
