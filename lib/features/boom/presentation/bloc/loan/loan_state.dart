import 'package:equatable/equatable.dart';
import 'package:boom_mobile/features/boom/data/models/loan_model.dart';
import 'package:boom_mobile/features/boom/data/models/borrower_model.dart';

class LoanState extends Equatable {
  final List<LoanModel> loans;
  final bool isLoadingLoans;

  final List<BorrowerModel> searchResults;
  final bool isSearchingBorrower;
  final BorrowerModel? selectedBorrower;

  final String? errorMessage;
  final String? successMessage;

  const LoanState({
    this.loans = const [],
    this.isLoadingLoans = false,
    this.searchResults = const [],
    this.isSearchingBorrower = false,
    this.selectedBorrower,
    this.errorMessage,
    this.successMessage,
  });

  LoanState copyWith({
    List<LoanModel>? loans,
    bool? isLoadingLoans,
    List<BorrowerModel>? searchResults,
    bool? isSearchingBorrower,
    BorrowerModel? selectedBorrower,
    String? errorMessage,
    String? successMessage,
  }) {
    return LoanState(
      loans: loans ?? this.loans,
      isLoadingLoans: isLoadingLoans ?? this.isLoadingLoans,
      searchResults: searchResults ?? this.searchResults,
      isSearchingBorrower: isSearchingBorrower ?? this.isSearchingBorrower,
      selectedBorrower: selectedBorrower ?? this.selectedBorrower,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    loans,
    isLoadingLoans,
    searchResults,
    isSearchingBorrower,
    selectedBorrower,
    errorMessage,
    successMessage,
  ];
}
