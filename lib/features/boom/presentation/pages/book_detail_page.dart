import 'package:boom_mobile/features/boom/presentation/pages/add_loan_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/book_model.dart';
import '../bloc/book/book_bloc.dart';
import '../bloc/book/book_event.dart';
import 'add_book_page.dart';

class BookDetailPage extends StatefulWidget {
  final BookModel book;

  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late TextEditingController _pageController;
  late String _currentStatus;
  late int _currentPage;

  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _pageController = TextEditingController(
      text: widget.book.currentPage.toString(),
    );
    _currentStatus = widget.book.status;
    _currentPage = widget.book.currentPage;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _sanitizeUrl(String url) {
    const String myIp = "192.168.137.1";
    if (url.contains("localhost")) return url.replaceAll("localhost", myIp);
    return url;
  }

  void _updateLocalState(String status, int page) {
    if (status == 'dipinjam') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddLoanPage(preSelectedBookId: widget.book.bookId),
        ),
      );

      return;
    }

    int finalPage = page;
    if (finalPage < 0) finalPage = 0;
    if (finalPage > widget.book.totalPages) finalPage = widget.book.totalPages;

    setState(() {
      _currentStatus = status;
      _currentPage = finalPage;
      _pageController.text = finalPage.toString();
      _isDirty = true;
    });
  }

  void _saveChanges() {
    print("Tombol Simpan Ditekan!");
    context.read<BookBloc>().add(
      UpdateBookProgressEvent(
        bookId: widget.book.bookId,
        statusBaca: _currentStatus,
        currentPage: _currentPage,
      ),
    );
    Navigator.pop(context, true);
  }

  void _deleteBook() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Buku?"),
        content: const Text("Tindakan ini tidak dapat dibatalkan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              print("Konfirmasi Hapus Ditekan!");
              Navigator.pop(ctx);
              context.read<BookBloc>().add(DeleteBookEvent(widget.book.bookId));
              Navigator.pop(context, true);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fixedUrl = _sanitizeUrl(widget.book.coverUrl);
    final bool hasImage = fixedUrl.isNotEmpty && fixedUrl != '-';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Detail Buku",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteBook,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddBookPage(book: widget.book),
                ),
              );

              if (result == true) {
                if (!mounted) return;
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: hasImage
                      ? Image.network(
                          fixedUrl,
                          width: 140,
                          height: 210,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderBox(),
                        )
                      : _placeholderBox(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                widget.book.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainBlack,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                widget.book.author,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Update Status Baca",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _StatusButton(
                  label: "Belum dibaca",
                  color: StatusColors.belumDibaca,
                  isActive: _currentStatus == 'belum_dibaca',
                  onTap: () => _updateLocalState('belum_dibaca', 0),
                ),
                _StatusButton(
                  label: "Sedang dibaca",
                  color: StatusColors.sedangDibaca,
                  isActive: _currentStatus == 'sedang_dibaca',
                  onTap: () => _updateLocalState(
                    'sedang_dibaca',
                    _currentPage == 0 ? 1 : _currentPage,
                  ),
                ),
                _StatusButton(
                  label: "Selesai!",
                  color: StatusColors.selesai,
                  isActive: _currentStatus == 'selesai',
                  onTap: () =>
                      _updateLocalState('selesai', widget.book.totalPages),
                ),
                _StatusButton(
                  label: "Dipinjam",
                  color: StatusColors.dipinjam,
                  isActive: _currentStatus == 'dipinjam',
                  onTap: () => _updateLocalState('dipinjam', _currentPage),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Halaman saat ini",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        "${widget.book.totalPages > 0 ? ((_currentPage / widget.book.totalPages) * 100).toInt() : 0}% Selesai",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pageController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (val) {
                            final page = int.tryParse(val) ?? _currentPage;
                            _updateLocalState('sedang_dibaca', page);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "/ ${widget.book.totalPages}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _QuickAddButton(
                        val: 5,
                        onTap: () => _updateLocalState(
                          'sedang_dibaca',
                          _currentPage + 5,
                        ),
                      ),
                      _QuickAddButton(
                        val: 10,
                        onTap: () => _updateLocalState(
                          'sedang_dibaca',
                          _currentPage + 10,
                        ),
                      ),
                      _QuickAddButton(
                        val: 20,
                        onTap: () => _updateLocalState(
                          'sedang_dibaca',
                          _currentPage + 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isDirty ? _saveChanges : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF00),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Simpan Perubahan",
                  style: TextStyle(
                    color: _isDirty ? Colors.black : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            const Text(
              "Informasi Detail",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildInfoRow("Penerbit", widget.book.publisher),
            _buildInfoRow("Kategori", widget.book.categoryName),
            _buildInfoRow("Total Halaman", "${widget.book.totalPages} Lembar"),
            _buildInfoRow(
              "ISBN / ID",
              widget.book.bookId.substring(0, 8).toUpperCase(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _placeholderBox() {
    return Container(
      width: 140,
      height: 210,
      color: Colors.grey[300],
      child: const Icon(Icons.book, size: 50, color: Colors.grey),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              value.isEmpty || value == '-' ? 'Tidak ada data' : value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;
  const _StatusButton({
    required this.label,
    required this.color,
    required this.isActive,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? Border.all(color: Colors.black, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final int val;
  final VoidCallback onTap;
  const _QuickAddButton({required this.val, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "+$val Hal",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
