// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:boom_mobile/core/utils/central_notification.dart';

import '../../../../injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/loan/loan_state.dart';
import '../pages/add_loan_page.dart';
import 'package:flutter/material.dart';
import '../bloc/loan/loan_bloc.dart';
import '../bloc/loan/loan_event.dart';

class LoanPage extends StatelessWidget {
  const LoanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<LoanBloc>()..add(GetLoansEvent(isHistory: false)),
      child: const _LoanView(),
    );
  }
}

class _LoanView extends StatelessWidget {
  const _LoanView();

  Future<void> _onRefresh(BuildContext context, bool isHistoryTab) async {
    context.read<LoanBloc>().add(GetLoansEvent(isHistory: isHistoryTab));
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "Daftar Peminjaman",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          automaticallyImplyLeading: false,

          bottom: TabBar(
            labelColor: AppColors.mainBlack,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.mainBlack,
            onTap: (index) {
              final isHistory = index == 1;
              context.read<LoanBloc>().add(GetLoansEvent(isHistory: isHistory));
            },
            tabs: const [
              Tab(text: "Sedang Dipinjam"),
              Tab(text: "Riwayat"),
            ],
          ),
        ),

        body: BlocConsumer<LoanBloc, LoanState>(
          listener: (context, state) {
            if (state.successMessage != null) {
              showCentralNotification(
                context,
                state.successMessage!,
                isError: false,
              );

              context.read<LoanBloc>().add(GetLoansEvent(isHistory: false));
            } else if (state.errorMessage != null && state.loans.isNotEmpty) {
              showCentralNotification(
                context,
                state.errorMessage!,
                isError: true,
              );
            }
          },
          builder: (context, state) {
            if (state.isLoadingLoans && state.loans.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null && state.loans.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => _onRefresh(context, false),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    Center(
                      child: Text(
                        "Gagal memuat: ${state.errorMessage}",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state.loans.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => _onRefresh(context, false),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          const Text("Tidak ada data peminjaman."),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _onRefresh(context, false),
              color: AppColors.mainBlack,
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.loans.length,
                itemBuilder: (context, index) {
                  final loan = state.loans[index];
                  final bool isReturned = loan.isReturned == 1;
                  final bool hasNotes =
                      loan.notes != null && loan.notes!.isNotEmpty;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: AppColors.mainBlack,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loan.borrowerName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppColors.mainWhiteBg,
                                      ),
                                    ),
                                    Text(
                                      loan.bookTitle,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (hasNotes) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        "Catatan: ${loan.notes}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              if (!isReturned)
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: AppColors.mainWhiteBg,
                                  ),
                                  tooltip: "Edit Peminjaman",
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AddLoanPage(existingLoan: loan),
                                      ),
                                    );

                                    if (result == true) {
                                      if (!context.mounted) return;
                                      _onRefresh(context, false);
                                    }
                                  },
                                ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isReturned ? "Dikembalikan" : "Jatuh Tempo",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    loan.returnDate ?? '-',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isReturned
                                          ? AppColors.mainWhiteBg
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),

                              if (!isReturned)
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<LoanBloc>().add(
                                      ReturnBookEvent(loan.loanId, loan.bookId),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text(
                                    "Dikembalikan",
                                    style: TextStyle(
                                      color: AppColors.mainBlack,
                                    ),
                                  ),
                                )
                              else
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Dikembalikan",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),

        floatingActionButton: FloatingActionButton(
          heroTag: "btn_add_loan",
          backgroundColor: AppColors.lightGreen,
          child: const Icon(Icons.add, color: AppColors.mainBlack),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddLoanPage()),
            );

            if (result == true) {
              print("Data Peminjaman Baru Disimpan. Menunggu refresh...");

              if (!context.mounted) return;

              await Future.delayed(const Duration(milliseconds: 500));

              context.read<LoanBloc>().add(GetLoansEvent(isHistory: false));
            }
          },
        ),
      ),
    );
  }
}
