import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go(AppRoutes.login);
        }
      },
      builder: (context, state) {
        String name = 'Guest User';
        String email = 'Login to sync data';
        String phone = '';

        if (state is Authenticated) {
          name = state.user.name;
          email = state.user.email;
          phone = state.user.phone;
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.primaryGreen,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryGreen, Color(0xFF2C4A2C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'G',
                              style: const TextStyle(
                                fontSize: 32,
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            name,
                            style: const TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email.isNotEmpty ? email : phone,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  _buildSectionHeader('MY ACCOUNT'),
                  _buildListTile(Iconsax.user, 'Personal Information', onTap: () {}),
                  _buildListTile(Iconsax.location, 'Delivery Addresses', onTap: () {}),
                  _buildListTile(Iconsax.receipt, 'My Orders', onTap: () => context.go(AppRoutes.orders)),
                  _buildListTile(Iconsax.heart, 'Wishlist', trailing: 'Coming Soon'),
                  
                  const SizedBox(height: 16),
                  _buildSectionHeader('PREFERENCES'),
                  _buildListTile(Iconsax.notification, 'Notifications', trailing: const Switch(value: true, onChanged: null)),
                  _buildListTile(Iconsax.moon, 'Dark Mode', trailing: const Switch(value: false, onChanged: null)),
                  _buildListTile(Iconsax.global, 'Language', trailing: 'English'),
                  
                  const SizedBox(height: 16),
                  _buildSectionHeader('SUPPORT'),
                  _buildListTile(Iconsax.message_question, 'Help & Support', onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support Center')));
                  }),
                  _buildListTile(Iconsax.star, 'Rate the App'),
                  _buildListTile(Iconsax.document, 'Terms & Privacy Policy'),
                  _buildListTile(Iconsax.info_circle, 'About Farooque Kirana', onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (c) => Container(
                        padding: const EdgeInsets.all(24),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(AppStrings.appName, style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 24)),
                            SizedBox(height: 8),
                            Text('Version 1.0.0'),
                            SizedBox(height: 16),
                            Text('Your neighborhood trusted grocery partner.'),
                          ],
                        ),
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListTile(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () {
                                  context.pop();
                                  context.read<AuthBloc>().add(AuthLogoutRequested());
                                },
                                child: const Text('Logout', style: TextStyle(color: AppColors.errorRed)),
                              ),
                            ],
                          ),
                        );
                      },
                      leading: const Icon(Iconsax.logout, color: AppColors.errorRed),
                      title: const Text('Logout', style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: AppColors.errorRed.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, {dynamic trailing, VoidCallback? onTap}) {
    Widget? trailingWidget;
    if (trailing is Widget) {
      trailingWidget = trailing;
    } else if (trailing is String) {
      trailingWidget = Text(trailing, style: const TextStyle(color: AppColors.textMuted));
    } else {
      trailingWidget = const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted);
    }

    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppColors.textDark),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: trailingWidget,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        const Divider(height: 1, indent: 56),
      ],
    );
  }
}
