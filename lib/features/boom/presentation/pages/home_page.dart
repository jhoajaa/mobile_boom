// ignore_for_file: use_build_context_synchronously, unnecessary_underscores, avoid_print
import 'package:boom_mobile/features/boom/presentation/pages/add_book_page.dart';
import 'package:boom_mobile/features/boom/presentation/pages/book_detail_page.dart';
import 'package:boom_mobile/features/boom/presentation/pages/loan_page.dart';
import 'package:boom_mobile/features/boom/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/responsive_layout.dart';
import '../bloc/book/book_bloc.dart';
import '../bloc/book/book_event.dart';
import '../bloc/book/book_state.dart';
import '../../data/models/book_model.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<BookBloc>().add(GetBooksEvent());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ResponsiveLayout(
        mobile: _MobileHomeView(),
        tablet: _TabletHomeView(),
      ),
    );
  }
}

class _MobileHomeView extends StatefulWidget {
  const _MobileHomeView();

  @override
  State<_MobileHomeView> createState() => _MobileHomeViewState();
}

class _MobileHomeViewState extends State<_MobileHomeView> {
  int _selectedIndex = 0;
  String _searchQuery = "";

  Future<void> _onRefresh() async {
    context.read<BookBloc>().add(GetBooksEvent());
    await Future.delayed(const Duration(seconds: 1));
  }

  List<Widget> get _pages => [
    _buildHomeBody(),
    const LoanPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: _selectedIndex == 0
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: 60,
              title: Image.asset('assets/images/logo_boom_b.png', height: 32),
              centerTitle: false,
            )
          : null,

      body: _selectedIndex == 0 ? _buildHomeBody() : _pages[_selectedIndex],

      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddBookPage()),
                );
                if (result == true) {
                  if (!mounted) return;
                  context.read<BookBloc>().add(GetBooksEvent());
                }
              },
              backgroundColor: const Color(0xFF00FF00),
              child: const Icon(Icons.add, color: AppColors.mainBlack),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.mainBlack,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);

          if (index == 0) {
            context.read<BookBloc>().add(GetBooksEvent());
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Peminjaman"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  Widget _buildHomeBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: "Cari judul atau penulis...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<BookBloc, BookState>(
              builder: (context, state) {
                if (state is BookLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BookError) {
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        ),
                        Center(
                          child: Text(
                            "Error: ${state.message}",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is BookLoaded) {
                  final filteredBooks = state.books.where((book) {
                    final query = _searchQuery.toLowerCase();
                    final title = book.title.toLowerCase();
                    final author = book.author.toLowerCase();
                    return title.contains(query) || author.contains(query);
                  }).toList();

                  if (filteredBooks.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                          ),
                          const Center(child: Text("Buku tidak ditemukan")),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: AppColors.mainBlack,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        return BookListTile(
                          book: filteredBooks[index],
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    BookDetailPage(book: filteredBooks[index]),
                              ),
                            );
                            if (result == true) {
                              if (!mounted) return;
                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );
                              context.read<BookBloc>().add(GetBooksEvent());
                            }
                          },
                        );
                      },
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabletHomeView extends StatefulWidget {
  const _TabletHomeView();

  @override
  State<_TabletHomeView> createState() => _TabletHomeViewState();
}

class _TabletHomeViewState extends State<_TabletHomeView> {
  BookModel? _selectedBook;
  String _searchQuery = "";

  Future<void> _onRefresh() async {
    context.read<BookBloc>().add(GetBooksEvent());
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF00FF00),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Row(
        children: [
          Container(
            width: 250,
            color: AppColors.mainBlack,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/images/logo_boom_w.png', height: 50),
                const SizedBox(height: 60),
                _buildDrawerItem(Icons.home, "Beranda", true),
                _buildDrawerItem(Icons.book, "Peminjaman Buku", false),
                _buildDrawerItem(Icons.person, "Profil Pengguna", false),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  child: _buildDrawerItem(
                    Icons.logout,
                    "Keluar Akun",
                    false,
                    isLogout: true,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Cari buku...",
                      suffixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: BlocBuilder<BookBloc, BookState>(
                      builder: (context, state) {
                        if (state is BookLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is BookLoaded) {
                          final filteredBooks = state.books.where((book) {
                            final query = _searchQuery.toLowerCase();
                            return book.title.toLowerCase().contains(query) ||
                                book.author.toLowerCase().contains(query);
                          }).toList();

                          if (filteredBooks.isEmpty) {
                            return RefreshIndicator(
                              onRefresh: _onRefresh,
                              child: ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.3,
                                  ),
                                  const Center(
                                    child: Text("Buku tidak ditemukan"),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (_selectedBook == null &&
                              filteredBooks.isNotEmpty) {
                            Future.microtask(() {
                              setState(() {
                                _selectedBook = filteredBooks.first;
                              });
                            });
                          }

                          return RefreshIndicator(
                            onRefresh: _onRefresh,
                            color: AppColors.mainBlack,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: filteredBooks.length,
                              itemBuilder: (context, index) {
                                final book = filteredBooks[index];
                                return BookListTile(
                                  book: book,
                                  isSelected:
                                      _selectedBook?.bookId == book.bookId,
                                  onTap: () async {
                                    print(
                                      "Masuk ke Detail Buku: ${book.title}",
                                    );

                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BookDetailPage(
                                          book: filteredBooks[index],
                                        ),
                                      ),
                                    );

                                    print(
                                      "Kembali dari detail. Result: $result",
                                    );

                                    if (result == true) {
                                      print("Melakukan Refresh Otomatis...");

                                      if (!context.mounted) return;

                                      await Future.delayed(
                                        const Duration(milliseconds: 500),
                                      );

                                      context.read<BookBloc>().add(
                                        GetBooksEvent(),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: _selectedBook == null
                ? Container(color: AppColors.mainBlack)
                : Container(
                    color: AppColors.mainBlack,
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              (_selectedBook!.coverUrl.isNotEmpty &&
                                  _selectedBook!.coverUrl != '-')
                              ? Image.network(
                                  _selectedBook!.coverUrl,
                                  height: 300,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 300,
                                    width: 200,
                                    color: Colors.grey[800],
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 50,
                                          color: Colors.white54,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "Error Load",
                                          style: TextStyle(
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 300,
                                  width: 200,
                                  color: Colors.grey[800],
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.book,
                                        size: 50,
                                        color: Colors.white54,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "No Cover",
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          _selectedBook!.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedBook!.author,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 30),
                        LinearProgressIndicator(
                          value: _selectedBook!.progressPercentage,
                          color: const Color(0xFF00FF00),
                          backgroundColor: Colors.grey,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${(_selectedBook!.progressPercentage * 100).toInt()}%",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              child: const Text(
                                "Lanjut Baca",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String label,
    bool isActive, {
    bool isLogout = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: isLogout
                ? Colors.red
                : (isActive ? Colors.white : Colors.grey),
            size: 28,
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: isLogout
                  ? Colors.red
                  : (isActive ? Colors.white : Colors.grey),
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class BookListTile extends StatelessWidget {
  final BookModel book;
  final VoidCallback onTap;
  final bool isSelected;

  const BookListTile({
    super.key,
    required this.book,
    required this.onTap,
    this.isSelected = false,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return StatusColors.selesai;
      case 'sedang_dibaca':
      case 'sedang dibaca':
        return StatusColors.sedangDibaca;
      case 'dipinjam':
        return StatusColors.dipinjam;
      case 'belum_dibaca':
      case 'belum dibaca':
      default:
        return StatusColors.belumDibaca;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'belum_dibaca':
      case 'belum dibaca':
        return Colors.black;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasValidImage = book.coverUrl.isNotEmpty && book.coverUrl != '-';

    final statusColor = _getStatusColor(book.status);
    final statusTextColor = _getStatusTextColor(book.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[900] : AppColors.mainBlack,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: Colors.green, width: 2) : null,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: hasValidImage
                  ? Image.network(
                      book.coverUrl,
                      width: 60,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 90,
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 60,
                      height: 90,
                      color: Colors.grey[800],
                      child: const Icon(Icons.book, color: Colors.white54),
                    ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          book.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          book.statusDisplay,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: book.progressPercentage,
                          backgroundColor: Colors.grey[700],
                          color: const Color(0xFF00FF00),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${(book.progressPercentage * 100).toInt()}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
