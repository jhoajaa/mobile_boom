import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:boom_mobile/core/constants/api_const.dart';
import 'package:boom_mobile/features/boom/data/models/loan_model.dart';
import 'package:boom_mobile/features/boom/data/models/borrower_model.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/loan/loan_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'loan_event.dart';

class LoanBloc extends Bloc<LoanEvent, LoanState> {
  final Dio dio;

  LoanBloc({required this.dio}) : super(const LoanState()) {
    on<GetLoansEvent>(_onGetLoans);
    on<ReturnBookEvent>(_onReturnBook);
    on<AddLoanEvent>(_onAddLoan);
    on<UpdateLoanEvent>(_onUpdateLoan);

    on<SearchBorrowerEvent>(
      _onSearchBorrower,
      transformer: (events, mapper) {
        return events
            .debounceTime(const Duration(milliseconds: 500))
            .asyncExpand(mapper); 
      },
    );

    on<SelectBorrowerEvent>(_onSelectBorrower);
  }

  Future<void> _onGetLoans(GetLoansEvent event, Emitter<LoanState> emit) async {
    emit(state.copyWith(isLoadingLoans: true, errorMessage: null));

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(
          state.copyWith(
            isLoadingLoans: false,
            errorMessage: "User tidak ditemukan",
          ),
        );
        return;
      }

      final String statusParam = event.isHistory ? 'history' : 'active';

      final response = await dio.get(
        ApiConstants.loans,
        queryParameters: {'uid': user.uid, 'status': statusParam},
      );

      if (response.statusCode == 200) {
        final List raw = response.data;
        final loans = raw.map((e) => LoanModel.fromJson(e)).toList();

        emit(state.copyWith(isLoadingLoans: false, loans: loans));
      } else {
        emit(
          state.copyWith(
            isLoadingLoans: false,
            errorMessage: "Gagal memuat data peminjaman",
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoadingLoans: false, errorMessage: "Error: $e"));
    }
  }

  Future<void> _onSearchBorrower(
    SearchBorrowerEvent event,
    Emitter<LoanState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(searchResults: []));
      return;
    }

    emit(state.copyWith(isSearchingBorrower: true));

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final response = await dio.get(
        ApiConstants.searchBorrower,
        queryParameters: {'q': event.query, 'uid': user.uid},
      );

      if (response.statusCode == 200) {
        final List raw = response.data;
        final borrowers = raw.map((e) => BorrowerModel.fromJson(e)).toList();
        emit(
          state.copyWith(isSearchingBorrower: false, searchResults: borrowers),
        );
      } else {
        emit(state.copyWith(isSearchingBorrower: false, searchResults: []));
      }
    } catch (e) {
      emit(state.copyWith(isSearchingBorrower: false, searchResults: []));
    }
  }

  void _onSelectBorrower(SelectBorrowerEvent event, Emitter<LoanState> emit) {
    emit(
      state.copyWith(
        selectedBorrower: event.selectedBorrower,
        searchResults: [],
      ),
    );
  }

  Future<void> _onAddLoan(AddLoanEvent event, Emitter<LoanState> emit) async {
    emit(state.copyWith(isLoadingLoans: true));

    try {
      final user = FirebaseAuth.instance.currentUser;
      final data = Map<String, dynamic>.from(event.loanData);
      data['user_id'] = user?.uid;

      if (state.selectedBorrower != null) {
        data['borrower_id'] = state.selectedBorrower!.borrowerId;

        data['name'] = state.selectedBorrower!.name;
        data['phone_number'] = state.selectedBorrower!.phoneNumber;
      }

      print("Mengirim Data ke API: $data");

      final response = await dio.post(ApiConstants.loans, data: data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final returnDate = data['return_date'];
        if (returnDate != null && returnDate.toString().isNotEmpty) {
          await _addToGoogleCalendar(
            title:
                "Pengembalian Buku: ${data['book_title_temp'] ?? 'Buku Perpustakaan'}",
            description:
                "Peminjam: ${data['name']}\nCatatan: ${data['notes'] ?? '-'}",
            date: returnDate.toString(),
          );
        }

        emit(
          state.copyWith(
            isLoadingLoans: false,
            successMessage: "Peminjaman berhasil disimpan!",

            selectedBorrower: null,
            searchResults: [],
          ),
        );

        add(GetLoansEvent());
      } else {
        emit(
          state.copyWith(
            isLoadingLoans: false,
            errorMessage:
                "Gagal: ${response.data['messages'] ?? 'Unknown Error'}",
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingLoans: false,
          errorMessage: "Gagal simpan peminjaman: $e",
        ),
      );
    }
  }

  Future<void> _onReturnBook(
    ReturnBookEvent event,
    Emitter<LoanState> emit,
  ) async {
    try {
      await dio.post(
        '${ApiConstants.loans}/return',
        data: {'loan_id': event.loanId, 'book_id': event.bookId},
      );

      add(GetLoansEvent());

      emit(state.copyWith(successMessage: "Buku berhasil dikembalikan!"));
    } catch (e) {
      emit(state.copyWith(errorMessage: "Gagal mengembalikan buku: $e"));
    }
  }

  Future<void> _onUpdateLoan(
    UpdateLoanEvent event,
    Emitter<LoanState> emit,
  ) async {
    emit(state.copyWith(isLoadingLoans: true));
    try {
      final response = await dio.put(
        '${ApiConstants.loans}/${event.loanId}',
        data: event.data,
      );

      if (response.statusCode == 200) {
        emit(
          state.copyWith(
            isLoadingLoans: false,
            successMessage: "Data berhasil diperbarui!",
          ),
        );
        add(GetLoansEvent());
      } else {
        emit(
          state.copyWith(
            isLoadingLoans: false,
            errorMessage:
                "Gagal update: ${response.data['messages'] ?? 'Unknown'}",
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(isLoadingLoans: false, errorMessage: "Error update: $e"),
      );
    }
  }

  Future<void> _addToGoogleCalendar({
    required String title,
    required String description,
    required String date,
  }) async {
    try {
      DateTime parsedDate = DateTime.parse(date);

      DateTime startDate = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        9,
        0,
        0,
      );
      DateTime endDate = startDate.add(const Duration(hours: 1));

      final Event event = Event(
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
        allDay: false,
      );
      await Add2Calendar.addEvent2Cal(event);
    } catch (e) {
      print("Error Add Calendar: $e");
    }
  }
}
