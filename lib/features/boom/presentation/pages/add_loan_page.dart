import 'package:boom_mobile/core/constants/api_const.dart';
import 'package:boom_mobile/features/boom/data/models/loan_model.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/book/book_bloc.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/book/book_event.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/book/book_state.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/loan/loan_bloc.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/loan/loan_event.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/loan/loan_state.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart' as di;

class AddLoanPage extends StatelessWidget {
  final String? preSelectedBookId;
  final LoanModel? existingLoan;

  const AddLoanPage({super.key, this.preSelectedBookId, this.existingLoan});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<LoanBloc>()),
        BlocProvider(create: (_) => di.sl<BookBloc>()..add(GetBooksEvent())),
      ],
      child: _AddLoanView(
        preSelectedBookId: preSelectedBookId,
        existingLoan: existingLoan,
      ),
    );
  }
}

class BorrowerSuggestion {
  final String name;
  final String phone;
  const BorrowerSuggestion(this.name, this.phone);
}

class _AddLoanView extends StatefulWidget {
  final String? preSelectedBookId;
  final LoanModel? existingLoan;

  const _AddLoanView({this.preSelectedBookId, this.existingLoan});

  @override
  State<_AddLoanView> createState() => _AddLoanViewState();
}

class _AddLoanViewState extends State<_AddLoanView> {
  late TextEditingController _phoneController;
  late TextEditingController _notesController;
  late TextEditingController _dateController;

  String? _selectedBookId;
  DateTime? _selectedDate;
  String _inputName = "";
  String _tempBookTitle = "";

  bool get _isEditMode => widget.existingLoan != null;

  @override
  void initState() {
    super.initState();

    _inputName = widget.existingLoan?.borrowerName ?? '';

    _phoneController = TextEditingController(
      text: widget.existingLoan?.phoneNumber ?? '',
    );
    _notesController = TextEditingController(
      text: widget.existingLoan?.notes ?? '',
    );
    _dateController = TextEditingController(
      text: widget.existingLoan?.returnDate ?? '',
    );

    if (_isEditMode) {
      _selectedBookId = widget.existingLoan!.bookId;
      if (widget.existingLoan!.returnDate != null) {
        try {
          _selectedDate = DateTime.parse(widget.existingLoan!.returnDate!);
        } catch (_) {}
      }
    } else if (widget.preSelectedBookId != null) {
      _selectedBookId = widget.preSelectedBookId;
    }
  }

  Future<List<BorrowerSuggestion>> _searchBorrower(String query) async {
    if (query.length < 2) return [];

    final user = FirebaseAuth.instance.currentUser;
    try {
      final dio = di.sl<Dio>();
      final response = await dio.get(
        '${ApiConstants.baseUrl}/api/borrowers/search',
        queryParameters: {'q': query, 'uid': user?.uid},
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data
            .map(
              (json) => BorrowerSuggestion(
                json['name'] ?? '',
                json['phone_number'] ?? '',
              ),
            )
            .toList();
      }
    } catch (e) {
      print("Search Error: $e");
    }
    return [];
  }

  Future<void> _pickDate() async {
    final initial =
        _selectedDate ?? DateTime.now().add(const Duration(days: 7));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _submit(BuildContext context) {
    if (_selectedBookId == null || _inputName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Buku dan Nama wajib diisi!")),
      );
      return;
    }

    final data = {
      'book_id': _selectedBookId,
      'name': _inputName,
      'phone': _phoneController.text,
      'notes': _notesController.text,
      'return_date': _dateController.text,
    };

    if (_isEditMode) {
      context.read<LoanBloc>().add(
        UpdateLoanEvent(widget.existingLoan!.loanId, data),
      );
    } else {
      data['book_title_temp'] = _tempBookTitle;
      context.read<LoanBloc>().add(AddLoanEvent(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? "Edit Peminjaman" : "Tambah Peminjaman"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      backgroundColor: Colors.white,

      body: BlocListener<LoanBloc, LoanState>(
        listener: (context, state) {
          if (state is LoanSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is LoanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pilih Buku",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              AbsorbPointer(
                absorbing: _isEditMode,
                child: BlocBuilder<BookBloc, BookState>(
                  builder: (context, state) {
                    if (state is BookLoaded) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isEditMode
                                ? Colors.grey.shade300
                                : Colors.grey,
                          ),
                          color: _isEditMode
                              ? Colors.grey.shade100
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedBookId,
                            hint: const Text("Pilih buku"),
                            isExpanded: true,

                            items: state.books
                                .where((b) {
                                  return b.status != 'dipinjam' ||
                                      b.bookId == _selectedBookId;
                                })
                                .map((book) {
                                  return DropdownMenuItem(
                                    value: book.bookId,
                                    child: Text(
                                      book.title,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () => _tempBookTitle = book.title,
                                  );
                                })
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedBookId = val),
                          ),
                        ),
                      );
                    }
                    return const LinearProgressIndicator();
                  },
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Nama Peminjam",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              LayoutBuilder(
                builder: (context, constraints) {
                  return Autocomplete<BorrowerSuggestion>(
                    initialValue: TextEditingValue(text: _inputName),

                    optionsBuilder: (TextEditingValue textEditingValue) {
                      setState(() {
                        _inputName = textEditingValue.text;
                      });
                      return _searchBorrower(textEditingValue.text);
                    },

                    displayStringForOption: (BorrowerSuggestion option) =>
                        option.name,

                    onSelected: (BorrowerSuggestion selection) {
                      setState(() {
                        _inputName = selection.name;
                        _phoneController.text = selection.phone;
                      });
                    },

                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final option = options.elementAt(index);
                                return ListTile(
                                  title: Text(option.name),
                                  subtitle: Text(option.phone),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },

                    fieldViewBuilder:
                        (
                          context,
                          textEditingController,
                          focusNode,
                          onFieldSubmitted,
                        ) {
                          if (_isEditMode &&
                              textEditingController.text.isEmpty &&
                              _inputName.isNotEmpty) {
                            textEditingController.text = _inputName;
                          }

                          return TextField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            onChanged: (val) => _inputName = val,
                            decoration: const InputDecoration(
                              hintText: "Cari atau ketik nama baru...",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              suffixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                  );
                },
              ),

              const SizedBox(height: 20),

              _buildInput(
                "Nomor HP (Opsional)",
                _phoneController,
                "0800-0000-0000",
                isNumber: true,
              ),
              const SizedBox(height: 20),
              const Text(
                "Tanggal Pengembalian",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  hintText: "Pilih Tanggal",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 20),
              _buildInput("Catatan", _notesController, "...", maxLines: 3),
              const SizedBox(height: 40),

              BlocBuilder<LoanBloc, LoanState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (state is LoanLoading)
                          ? null
                          : () => _submit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: (state is LoanLoading)
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isEditMode ? "Simpan Perubahan" : "Simpan",
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

  Widget _buildInput(
    String label,
    TextEditingController ctrl,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
