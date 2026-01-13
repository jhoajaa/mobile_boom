import 'dart:io';
import 'package:boom_mobile/core/constants/api_const.dart';
import 'package:boom_mobile/features/boom/data/models/category_model.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/add_book/add_book_event.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/add_book/add_book_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoadCategoriesEvent extends AddBookEvent {}

class AddBookBloc extends Bloc<AddBookEvent, AddBookState> {
  final Dio dio;
  final ImagePicker _picker = ImagePicker();

  List<CategoryModel> _cachedCategories = [];

  AddBookBloc({required this.dio}) : super(AddBookInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<ScanBookEvent>(_onScanBook);
    on<SubmitBookEvent>(_onSubmitBook);
    on<UpdateBookEvent>(_onUpdateBook);
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<AddBookState> emit,
  ) async {
    emit(AddBookLoading());
    try {
      final response = await dio.get(ApiConstants.categories);

      if (response.statusCode == 200) {
        final List raw = response.data['data'] ?? [];
        _cachedCategories = raw.map((e) => CategoryModel.fromJson(e)).toList();
        emit(AddBookReady(_cachedCategories));
      } else {
        emit(const AddBookFailure("Gagal memuat kategori"));
      }
    } catch (e) {
      emit(AddBookFailure("Error memuat kategori: $e"));
    }
  }

  Future<void> _onScanBook(
    ScanBookEvent event,
    Emitter<AddBookState> emit,
  ) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo == null) return;

      emit(AddBookLoading());
      final File imageFile = File(photo.path);

      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      await textRecognizer.close();

      String query = recognizedText.text
          .replaceAll('\n', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      final googleResponse = await Dio().get(
        'https://www.googleapis.com/books/v1/volumes',
        queryParameters: {'q': query, 'maxResults': 1},
      );

      if (googleResponse.statusCode == 200) {
        final items = googleResponse.data['items'] as List?;
        if (items != null && items.isNotEmpty) {
          final volumeInfo = items[0]['volumeInfo'];

          String? detectedId;
          List<dynamic>? categories = volumeInfo['categories'];

          if (categories != null && categories.isNotEmpty) {
            String googleCat = categories[0].toString().toLowerCase();
            print("Kategori dari Google: $googleCat");

            for (var cat in _cachedCategories) {
              String dbCatName = cat.categoryName;

              bool isMatch(List<String> keywords) {
                for (var key in keywords) {
                  if (googleCat.contains(key)) return true;
                }
                return false;
              }

              if (dbCatName == 'Fiksi & Sastra' &&
                  isMatch(['fiction', 'literature', 'fantasy', 'mystery'])) {
                detectedId = cat.categoryId;
              } else if (dbCatName == 'Novel' && isMatch(['novel'])) {
                detectedId = cat.categoryId;
              } else if (dbCatName == 'Komik & Grafis' &&
                  isMatch(['comic', 'manga', 'graphic novel'])) {
                detectedId = cat.categoryId;
              } else if (dbCatName == 'Biografi & Memoar' &&
                  isMatch(['biography', 'autobiography', 'memoir'])) {
                detectedId = cat.categoryId;
              } else if (dbCatName == 'Bisnis & Ekonomi' &&
                  isMatch(['business', 'economics', 'finance', 'marketing'])) {
                detectedId = cat.categoryId;
              } else if (dbCatName == 'Teknologi & Komputer' &&
                  isMatch([
                    'computer',
                    'technology',
                    'software',
                    'programming',
                  ])) {
                detectedId = cat.categoryId;
              } else if (dbCatName == 'Sains & Alam' &&
                  isMatch([
                    'science',
                    'nature',
                    'physics',
                    'biology',
                    'chemistry',
                  ])) {
                detectedId = cat.categoryId;
              } else if (dbCatName == 'Sejarah' && isMatch(['history'])) {
                detectedId = cat.categoryId;
              } else if (dbCatName == 'Psikologi' && isMatch(['psychology'])) {
                detectedId = cat.categoryId;
              } else if (dbCatName == 'Pengembangan Diri' &&
                  isMatch(['self-help', 'motivation', 'success'])) {
                detectedId = cat.categoryId;
              } else if (dbCatName == 'Agama & Spiritual' &&
                  isMatch([
                    'religion',
                    'spiritual',
                    'islam',
                    'christian',
                    'bible',
                    'quran',
                  ])) {
                detectedId = cat.categoryId;
              } else if (dbCatName == 'Pendidikan' &&
                  isMatch(['education', 'study', 'teaching', 'textbook'])) {
                detectedId = cat.categoryId;
              } else if (dbCatName == 'Anak-anak' &&
                  isMatch(['children', 'juvenile', 'kids'])) {
                detectedId = cat.categoryId;
              } else if (dbCatName == 'Seni & Desain' &&
                  isMatch(['art', 'design', 'photography', 'architecture'])) {
                detectedId = cat.categoryId;
              } else if (dbCatName == 'Masakan & Makanan' &&
                  isMatch(['cooking', 'food', 'cookbook'])) {
                detectedId = cat.categoryId;
              } else if (dbCatName == 'Kesehatan & Bugar' &&
                  isMatch(['health', 'fitness', 'diet', 'medical'])) {
                detectedId = cat.categoryId;
              } else if (dbCatName == 'Travel' &&
                  isMatch(['travel', 'tourism'])) {
                detectedId = cat.categoryId;
              }

              if (detectedId != null) {
                print("Match Found: $dbCatName");
                break;
              }
            }
          }

          if (detectedId == null) {
            final other = _cachedCategories.firstWhere(
              (element) => element.categoryName.toLowerCase() == 'lainnya',
              orElse: () => _cachedCategories.isNotEmpty
                  ? _cachedCategories.first
                  : CategoryModel(categoryId: '', categoryName: ''),
            );
            detectedId = other.categoryId;
          }

          emit(
            AddBookScanned(
              volumeInfo,
              imageFile,
              _cachedCategories,
              detectedId,
            ),
          );
        } else {
          emit(AddBookScanned({}, imageFile, _cachedCategories, null));
        }
      }
    } catch (e) {
      emit(AddBookFailure("Error Scanning: $e"));
    }
  }

  Future<void> _onSubmitBook(
    SubmitBookEvent event,
    Emitter<AddBookState> emit,
  ) async {
    emit(AddBookLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(const AddBookFailure("Sesi habis. Login ulang."));
        return;
      }

      final Map<String, dynamic> finalData = Map.from(event.bookData);
      finalData['user_id'] = user.uid;

      if (finalData['category_id'] == null) {
        emit(const AddBookFailure("Kategori buku wajib dipilih!"));
        return;
      }

      FormData formData = FormData.fromMap(finalData);
      if ((event.bookData['cover_image_url'] == null ||
              event.bookData['cover_image_url'] == '') &&
          event.localImage != null) {
        String fileName = event.localImage!.path.split('/').last;
        formData.files.add(
          MapEntry(
            'cover_image',
            await MultipartFile.fromFile(
              event.localImage!.path,
              filename: fileName,
            ),
          ),
        );
      }

      final response = await dio.post(ApiConstants.books, data: formData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(AddBookSuccess());
      } else {
        emit(AddBookFailure("Gagal: ${response.statusCode}"));
      }
    } catch (e) {
      emit(AddBookFailure(e.toString()));
    }
  }

  Future<void> _onUpdateBook(
    UpdateBookEvent event,
    Emitter<AddBookState> emit,
  ) async {
    emit(AddBookLoading());
    try {
      final response = await dio.put(
        '${ApiConstants.books}/${event.bookId}',
        data: event.data,
      );

      if (response.statusCode == 200) {
        emit(AddBookSuccess());
      } else {
        emit(
          AddBookFailure(
            response.data['messages']?.toString() ?? "Gagal mengupdate buku",
          ),
        );
      }
    } catch (e) {
      emit(AddBookFailure("Error: $e"));
    }
  }
}
