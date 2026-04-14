import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:roya/core/router/route_names.dart';
import 'package:roya/core/storage/secure_storage.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/features/auth/data/repositories/auth_repository.dart';
import 'package:roya/features/profile/controllers/profile_controller.dart';
import 'package:roya/features/profile/views/store_settings_screen.dart';
import 'package:roya/features/profile/views/working_hours_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;

  ProfileController get c => Get.find<ProfileController>();

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('خروج'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoggingOut = true);
    try {
      if (Get.isRegistered<AuthRepository>()) {
        await Get.find<AuthRepository>().logout();
      }
    } catch (_) {
      // Always proceed with local logout, even if server logout fails.
    } finally {
      await SecureStorage.clearAll();
      if (mounted) {
        context.go(RouteNames.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(() {
              if (c.isLoading.value) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (c.errorMessage.isNotEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDECEA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        c.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: c.fetchProfile,
                        child: const Text(
                          'إعادة المحاولة',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final user = c.user.value;
              if (user == null) return const SizedBox.shrink();

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primary,
                          backgroundImage:
                              (user.logo != null && user.logo!.isNotEmpty)
                              ? CachedNetworkImageProvider(user.logo!)
                              : null,
                          child: (user.logo == null || user.logo!.isEmpty)
                              ? const Icon(
                                  Icons.store,
                                  color: Colors.white,
                                  size: 30,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name ?? 'Shop Owner',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (user.id != null)
                                Text(
                                  'المعرف: \${user.id}',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              // Open/Closed Status
                              if (user.isOpen != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: user.isOpen!
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: user.isOpen!
                                          ? Colors.green.withOpacity(0.3)
                                          : Colors.red.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        user.isOpen!
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        size: 16,
                                        color: user.isOpen!
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        user.isOpen! ? 'مفتوح الآن' : 'مغلق الآن',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: user.isOpen!
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              // Working Hours
                              if (user.openTime != null && user.closeTime != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${user.openTime} - ${user.closeTime}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    // Store Settings Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StoreSettingsScreen(),
                            ),
                          );
                          // Refresh profile after settings update
                          if (mounted) {
                            c.fetchProfile();
                          }
                        },
                        icon: const Icon(Icons.settings_outlined),
                        label: const Text(
                          'إعدادات المتجر',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Working Hours Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WorkingHoursScreen(),
                            ),
                          );
                          // Refresh profile after working hours update
                          if (mounted) {
                            c.fetchProfile();
                          }
                        },
                        icon: const Icon(Icons.access_time_filled),
                        label: const Text(
                          'ساعات العمل',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoggingOut ? null : _logout,
                icon: _isLoggingOut
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.logout_rounded),
                label: Text(
                  _isLoggingOut ? 'جار تسجيل الخروج...' : 'تسجيل الخروج',
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
