import 'package:equatable/equatable.dart';

abstract class LoanEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetLoansEvent extends LoanEvent {
  final bool isHistory;
  GetLoansEvent({this.isHistory = false});
  
  @override
  List<Object> get props => [isHistory];
}

class ReturnBookEvent extends LoanEvent {
  final String loanId;
  final String bookId;
  
  ReturnBookEvent(this.loanId, this.bookId);
}

class AddLoanEvent extends LoanEvent {
  final Map<String, dynamic> loanData;
  AddLoanEvent(this.loanData);
}

class UpdateLoanEvent extends LoanEvent {
  final String loanId;
  final Map<String, dynamic> data;

  UpdateLoanEvent(this.loanId, this.data);

  @override
  List<Object> get props => [loanId, data];
}