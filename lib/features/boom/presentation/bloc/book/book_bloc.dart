import 'package:boom_mobile/core/constants/api_const.dart';
import 'package:boom_mobile/core/database/database_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/book_model.dart';
import 'book_event.dart';
import 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final Dio dio;
  final DatabaseHelper dbHelper = DatabaseHelper();

  List<BookModel> _localBooksCache = [];

  BookBloc({required this.dio}) : super(BookInitial()) {
    on<GetBooksEvent>(_onGetBooks);
    on<UpdateBookProgressEvent>(_onUpdateProgress);
  }

  Future<void> _onGetBooks(GetBooksEvent event, Emitter<BookState> emit) async {
    emit(BookLoading());

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final uid = user.uid;
        print("🔍 Mengambil buku via API untuk UID: $uid");

        final response = await dio.get(
          ApiConstants.books,
          queryParameters: {'uid': uid},
        );

        if (response.statusCode == 200) {
          List rawList = [];
          if (response.data is Map && response.data.containsKey('data')) {
            rawList = response.data['data'];
          } else if (response.data is List) {
            rawList = response.data;
          }

          final books = rawList
              .map((json) => BookModel.fromJson(json))
              .toList();

          _localBooksCache = books;

          print("💾 Menyimpan ${books.length} buku ke SQLite...");
          await dbHelper.cacheBooks(books);

          emit(BookLoaded(books));
          return;
        }
      }
    } catch (e) {
      print("⚠️ Gagal koneksi API: $e. Mencoba ambil offline...");
    }

    try {
      print("📂 Mengambil data dari SQLite (Offline Mode)...");
      final localBooks = await dbHelper.getCachedBooks();

      _localBooksCache = localBooks;

      if (localBooks.isNotEmpty) {
        emit(BookLoaded(localBooks));
      } else {
        emit(
          const BookError(
            "Tidak ada koneksi internet dan belum ada data tersimpan.",
          ),
        );
      }
    } catch (e) {
      emit(BookError("Gagal memuat data lokal: $e"));
    }
  }

  Future<void> _onUpdateProgress(
    UpdateBookProgressEvent event,
    Emitter<BookState> emit,
  ) async {
    final index = _localBooksCache.indexWhere((b) => b.bookId == event.bookId);

    if (index != -1) {
      final oldBook = _localBooksCache[index];

      final newBook = oldBook.copyWith(
        status: event.statusBaca,
        currentPage: event.currentPage,
      );

      _localBooksCache[index] = newBook;

      emit(BookLoaded(List.from(_localBooksCache)));

      await dbHelper.cacheBooks(_localBooksCache);
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final response = await dio.post(
        ApiConstants.updateReadingProgress,
        data: {
          "user_id": user.uid,
          "book_id": event.bookId,
          "current_page": event.currentPage,
          "status_baca": event.statusBaca,
        },
      );

      if (response.statusCode != 200) {
        print("Gagal update server: ${response.statusCode}");
      }
    } catch (e) {
      print("Gagal update progress ke server: $e");
    }
  }
}
