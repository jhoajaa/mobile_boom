import 'package:boom_mobile/core/utils/central_notification.dart';
import 'package:boom_mobile/features/boom/data/models/loan_model.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/book/book_bloc.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/book/book_event.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/book/book_state.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/loan/loan_bloc.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/loan/loan_event.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/loan/loan_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class PhoneNumberFormatter extends TextInputFormatter {
  static String format(String input) {
    final text = input.replaceAll(RegExp(r'\D'), '');

    if (text.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write('-');
      }
      buffer.write(text[i]);
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formattedText = format(newValue.text);

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class _AddLoanView extends StatefulWidget {
  final String? preSelectedBookId;
  final LoanModel? existingLoan;

  const _AddLoanView({this.preSelectedBookId, this.existingLoan});

  @override
  State<_AddLoanView> createState() => _AddLoanViewState();
}

class _AddLoanViewState extends State<_AddLoanView> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;
  late TextEditingController _dateController;

  String? _selectedBookId;
  DateTime? _selectedDate;
  String _tempBookTitle = "";

  bool get _isEditMode => widget.existingLoan != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.existingLoan?.borrowerName ?? '',
    );

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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
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
    if (_selectedBookId == null || _nameController.text.trim().isEmpty) {
      showCentralNotification(
        context,
        "Buku dan Nama wajib diisi!",
        isError: true,
      );
      return;
    }

    final data = {
      'book_id': _selectedBookId,
      'name': _nameController.text.trim(),

      'phone': _phoneController.text.replaceAll(' ', ''),
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

  Widget _buildBorrowerSearchField() {
    return BlocBuilder<LoanBloc, LoanState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildInput(
              "Nama Peminjam",
              _nameController,
              "Ketik nama peminjam...",
              capitalization: TextCapitalization.words,
              onChanged: (value) {
                context.read<LoanBloc>().add(SearchBorrowerEvent(value));
              },

              suffixIcon: state.isSearchingBorrower
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.search, color: Colors.grey),
            ),

            if (state.searchResults.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                margin: const EdgeInsets.only(top: 0, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: state.searchResults.length,
                  itemBuilder: (context, index) {
                    final borrower = state.searchResults[index];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.mainBlack,
                        child: Text(
                          borrower.name.isNotEmpty
                              ? borrower.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: AppColors.lightGreen,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      title: Text(
                        borrower.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(borrower.phoneNumber),
                      onTap: () {
                        _nameController.text = borrower.name;

                        _phoneController.text = PhoneNumberFormatter.format(borrower.phoneNumber);

                        context.read<LoanBloc>().add(
                          SelectBorrowerEvent(borrower),
                        );

                        FocusScope.of(context).unfocus();
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
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
          if (state.successMessage != null) {
            showCentralNotification(
              context,
              state.successMessage!,
              isError: false,
            );

            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) Navigator.pop(context, true);
            });
          } else if (state.errorMessage != null && state.loans.isEmpty) {
            showCentralNotification(
              context,
              state.errorMessage!,
              isError: true,
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

              _buildBorrowerSearchField(),

              const SizedBox(height: 4),

              const Text(
                "Nomor HP (Opsional)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.number,

                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  PhoneNumberFormatter(),
                  LengthLimitingTextInputFormatter(16),
                ],
                decoration: const InputDecoration(
                  hintText: "08xx xxxx xxxx",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
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

              _buildInput(
                "Catatan (Opsional)",
                _notesController,
                capitalization: TextCapitalization.sentences,
                "Untuk catatan tambahan",
                maxLines: 3,
              ),

              const SizedBox(height: 40),

              BlocBuilder<LoanBloc, LoanState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (state.isLoadingLoans)
                          ? null
                          : () => _submit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: (state.isLoadingLoans)
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
    int maxLines = 1,
    TextCapitalization capitalization = TextCapitalization.sentences,
    Function(String)? onChanged,
    Widget? suffixIcon,
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
            maxLines: maxLines,
            textCapitalization: capitalization,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: suffixIcon,
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
