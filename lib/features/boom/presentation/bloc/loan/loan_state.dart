import 'package:boom_mobile/features/boom/data/models/loan_model.dart';
import 'package:equatable/equatable.dart';

abstract class LoanState extends Equatable {
  @override
  List<Object> get props => [];
}

class LoanInitial extends LoanState {}
class LoanLoading extends LoanState {}
class LoanLoaded extends LoanState {
  final List<LoanModel> loans;
  LoanLoaded(this.loans);
}
class LoanError extends LoanState {
  final String message;
  LoanError(this.message);
}
class LoanSuccess extends LoanState {
  final String message;
  LoanSuccess(this.message); 
}