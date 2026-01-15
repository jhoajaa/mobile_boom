import 'dart:io';
import 'package:boom_mobile/core/utils/central_notification.dart';
import 'package:boom_mobile/features/boom/data/models/book_model.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/add_book/add_book_event.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/add_book/add_book_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/add_book/add_book_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../data/models/category_model.dart';

class AddBookPage extends StatelessWidget {
  final BookModel? book;

  const AddBookPage({super.key, this.book});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddBookBloc(dio: di.sl()),
      child: _AddBookView(book: book),
    );
  }
}

class _AddBookView extends StatefulWidget {
  final BookModel? book;
  const _AddBookView({this.book});

  @override
  State<_AddBookView> createState() => _AddBookViewState();
}

class _AddBookViewState extends State<_AddBookView> {
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _publisherController;
  late TextEditingController _totalPagesController;

  String? _webCoverUrl;
  File? _localCoverFile;

  String? _selectedCategoryId;
  List<CategoryModel> _categories = [];

  bool get _isEditMode => widget.book != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.book?.title ?? '');
    _authorController = TextEditingController(text: widget.book?.author ?? '');
    _publisherController = TextEditingController(
      text: widget.book?.publisher ?? '',
    );
    _totalPagesController = TextEditingController(
      text: widget.book?.totalPages.toString() ?? '',
    );

    if (_isEditMode) {
      _webCoverUrl = widget.book!.coverUrl;
      _selectedCategoryId = widget.book!.categoryId;
    }

    context.read<AddBookBloc>().add(LoadCategoriesEvent());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _totalPagesController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    if (_selectedCategoryId == null) {
      showCentralNotification(
        context,
        "Harap pilih kategori buku!",
        isError: true,
      );
      return;
    }

    final data = {
      'title': _titleController.text,
      'author': _authorController.text,
      'publisher': _publisherController.text,
      'total_pages': int.tryParse(_totalPagesController.text) ?? 0,
      'cover_image_url': _webCoverUrl,
      'category_id': _selectedCategoryId,
    };

    if (_isEditMode) {
      context.read<AddBookBloc>().add(
        UpdateBookEvent(
          bookId: widget.book!.bookId,
          data: data,
          coverImage: _localCoverFile,
        ),
      );
    } else {
      context.read<AddBookBloc>().add(SubmitBookEvent(data, _localCoverFile));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isEditMode ? "Edit Buku" : "Tambah Buku Baru",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocListener<AddBookBloc, AddBookState>(
        listener: (context, state) {
          if (state is AddBookSuccess) {
            showCentralNotification(
              context,
              _isEditMode
                  ? "Buku berhasil diupdate!"
                  : "Buku berhasil disimpan!",
              isError: false,
            );
            Navigator.pop(context, true);
          } else if (state is AddBookFailure) {
            showCentralNotification(context, state.message, isError: true);
          } else if (state is AddBookReady) {
            setState(() {
              _categories = state.categories;

              if (_isEditMode && _selectedCategoryId != null) {
                bool exists = _categories.any(
                  (c) => c.categoryId == _selectedCategoryId,
                );
                if (!exists) _selectedCategoryId = null;
              }
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isEditMode) ...[
                InkWell(
                  onTap: () => context.read<AddBookBloc>().add(ScanBookEvent()),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.mainBlack, Colors.black87],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, color: Color(0xFF00FF00)),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Scan Otomatis (AI)",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Isi form & kategori otomatis",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 20),
              ],

              Center(
                child: GestureDetector(
                  child: Container(
                    width: 120,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _webCoverUrl != null && _webCoverUrl != '-'
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _webCoverUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (_localCoverFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _localCoverFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text(
                                      "Cover",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                )),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              _buildLabel("Judul Buku"),
              CustomTextField(hint: "Judul", controller: _titleController),
              const SizedBox(height: 16),

              _buildLabel("Penulis"),
              CustomTextField(hint: "Penulis", controller: _authorController),
              const SizedBox(height: 16),

              _buildLabel("Kategori Buku"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategoryId,
                    hint: Text(
                      "Pilih Kategori",
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.categoryId,
                        child: Text(cat.categoryName),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategoryId = value),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel("Penerbit"),
              CustomTextField(
                hint: "Penerbit",
                controller: _publisherController,
              ),
              const SizedBox(height: 16),

              _buildLabel("Jumlah Halaman"),
              CustomTextField(
                hint: "0",
                controller: _totalPagesController,
                isNumber: true,
              ),
              const SizedBox(height: 40),

              BlocBuilder<AddBookBloc, AddBookState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (state is AddBookLoading)
                          ? null
                          : () => _submitForm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: (state is AddBookLoading)
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isEditMode ? "Update Buku" : "Simpan Buku",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool isNumber;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.isNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
