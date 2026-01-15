import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:boom_mobile/core/constants/api_const.dart';
import 'package:boom_mobile/features/boom/data/models/loan_model.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/loan/loan_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'loan_event.dart';

class LoanBloc extends Bloc<LoanEvent, LoanState> {
  final Dio dio;

  LoanBloc({required this.dio}) : super(LoanInitial()) {
    on<GetLoansEvent>(_onGetLoans);
    on<ReturnBookEvent>(_onReturnBook);
    on<AddLoanEvent>(_onAddLoan);
    on<UpdateLoanEvent>(_onUpdateLoan);
  }

  Future<void> _onGetLoans(GetLoansEvent event, Emitter<LoanState> emit) async {
    emit(LoanLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(LoanError("User tidak ditemukan"));
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
        emit(LoanLoaded(loans));
      } else {
        emit(LoanError("Gagal memuat data peminjaman"));
      }
    } catch (e) {
      emit(LoanError("Error: $e"));
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
      emit(LoanSuccess("Buku berhasil dikembalikan!"));
    } catch (e) {
      emit(LoanError("Gagal mengembalikan buku: $e"));
    }
  }

  Future<void> _onAddLoan(AddLoanEvent event, Emitter<LoanState> emit) async {
    emit(LoanLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      final data = Map<String, dynamic>.from(event.loanData);
      data['user_id'] = user?.uid;

      print("Mengirim Data ke API: $data");

      final response = await dio.post(ApiConstants.loans, data: data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final returnDate = data['return_date'];
        if (returnDate != null && returnDate.toString().isNotEmpty) {
          print("Mencoba trigger Google Calendar...");

          await _addToGoogleCalendar(
            title:
                "Pengembalian Buku: ${data['book_title_temp'] ?? 'Buku Perpustakaan'}",
            description:
                "Peminjam: ${data['name']}\nCatatan: ${data['notes'] ?? '-'}",
            date: returnDate.toString(),
          );
        } else {
          print("Tanggal kosong, skip kalender");
        }

        emit(LoanSuccess("Peminjaman berhasil disimpan!"));
        add(GetLoansEvent());
      } else {
        emit(
          LoanError("Gagal: ${response.data['messages'] ?? 'Unknown Error'}"),
        );
      }
    } catch (e) {
      print("Error: $e");
      emit(LoanError("Gagal simpan peminjaman: $e"));
    }
  }

  Future<void> _onUpdateLoan(
    UpdateLoanEvent event,
    Emitter<LoanState> emit,
  ) async {
    emit(LoanLoading());
    try {
      final response = await dio.put(
        '${ApiConstants.loans}/${event.loanId}', 
        data: event.data,
      );

      if (response.statusCode == 200) {
        emit(LoanSuccess("Data berhasil diperbarui!"));
        add(GetLoansEvent()); // Refresh list
      } else {
        emit(
          LoanError("Gagal update: ${response.data['messages'] ?? 'Unknown'}"),
        );
      }
    } catch (e) {
      emit(LoanError("Error update: $e"));
    }
  }

  Future<void> _addToGoogleCalendar({
    required String title,
    required String description,
    required String date,
  }) async {
    try {
      DateTime startDate = DateTime.parse(date);

      DateTime endDate = startDate;

      final Event event = Event(
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
        allDay: true,
      );

      print("Membuka Native Calendar App...");
      await Add2Calendar.addEvent2Cal(event);
    } catch (e) {
      print("Error Add Calendar: $e");
    }
  }
}
