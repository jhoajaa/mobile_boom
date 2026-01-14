import 'package:boom_mobile/features/boom/presentation/bloc/profile/profile_bloc.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/profile/profile_event.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/profile/profile_state.dart';
import 'package:boom_mobile/features/boom/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart' as di;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(dio: di.sl())..add(GetProfileEvent()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _onRefresh(BuildContext context) async {
    context.read<ProfileBloc>().add(GetProfileEvent());

    await Future.delayed(const Duration(seconds: 1));
  }

  void _showEditNameDialog(BuildContext context, String? currentName) {
    final controller = TextEditingController(text: currentName ?? '');

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Ubah Nama", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Masukkan nama lengkap",
              hintStyle: TextStyle(color: Colors.grey[500]),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<ProfileBloc>().add(
                    UpdateNameEvent(controller.text),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text(
                "Simpan",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
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
      backgroundColor: AppColors.mainBlack,
      appBar: AppBar(
        title: const Text(
          "Profil Saya",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.mainBlack,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (state is ProfileLoaded) {
            final user = state.user;
            final hasName = user.fullName != null && user.fullName!.isNotEmpty;

            return RefreshIndicator(
              onRefresh: () => _onRefresh(context),
              color: AppColors.mainBlack,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Halo,",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hasName ? user.fullName! : "Set Nama Kamu",
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[800]!),
                            ),
                            child: IconButton(
                              onPressed: () =>
                                  _showEditNameDialog(context, user.fullName),
                              icon: const Icon(Icons.edit, color: Colors.white),
                              tooltip: "Ubah Nama",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 40),

                      _buildStatCard(
                        "Koleksi Bukumu",
                        user.totalBooks.toString(),
                        AppColors.lightGreen,
                        AppColors.mainBlack,
                        icon: Icons.library_books,
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              "Sudah Dibaca",
                              user.finishedBooks.toString(),
                              Colors.grey[900]!,
                              Colors.greenAccent,
                              icon: Icons.check_circle_outline,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              "Dipinjam Org",
                              user.activeLoans.toString(),
                              Colors.grey[900]!,
                              Colors.orangeAccent,
                              icon: Icons.people_outline,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      Center(
                        child: TextButton.icon(
                          onPressed: () => _confirmLogout(context),
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            "Keluar Akun",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ProfileBloc>().add(GetProfileEvent()),
                    child: const Text("Coba Lagi"),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Keluar Akun?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Anda harus login kembali untuk masuk.",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProfileBloc>().add(LogoutEvent());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color bgColor,
    Color textColor, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (icon != null)
                Icon(icon, color: textColor.withOpacity(0.3), size: 32),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
