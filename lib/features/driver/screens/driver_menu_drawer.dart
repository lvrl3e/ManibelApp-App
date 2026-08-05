import 'package:flutter/material.dart';

// Relative import directly accessing core/constants
import '../../../core/constants/app_colors.dart';

class DriverMenuDrawer extends StatelessWidget {
  final String driverName;
  final String driverId;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onQrCodeTap;
  final VoidCallback? onLogoutTap;

  const DriverMenuDrawer({
    super.key,
    required this.driverName,
    required this.driverId,
    this.onSettingsTap,
    this.onQrCodeTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.78, // Comfortable side menu width
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dynamic Driver Header Profile Row
              Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFD9D9D9),
                    child: Icon(
                      Icons.person,
                      size: 36,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driverName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Driver ID:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.logoBlue,
                          ),
                        ),
                        Text(
                          driverId,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.logoBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Menu Button 1: Settings
              _buildMenuButton(
                context: context,
                icon: Icons.settings_suggest_rounded,
                label: 'Settings',
                backgroundColor: AppColors.settingsTileBg,
                borderColor: AppColors.settingsTileBorder,
                iconColor: AppColors.settingsIconColor,
                textColor: AppColors.textPrimary,
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  if (onSettingsTap != null) {
                    onSettingsTap!();
                  } else {
                    // TODO: Navigate to Driver Settings Screen
                  }
                },
              ),
              const SizedBox(height: 16),

              // Menu Button 2: Your QR Code
              _buildMenuButton(
                context: context,
                icon: Icons.qr_code_2_rounded,
                label: 'Your QR Code',
                backgroundColor: AppColors.qrTileBg,
                borderColor: AppColors.qrTileBorder,
                iconColor: AppColors.qrIconColor,
                textColor: AppColors.qrIconColor,
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  if (onQrCodeTap != null) {
                    onQrCodeTap!();
                  } else {
                    // TODO: Open Driver QR Code Modal/Screen
                  }
                },
              ),
              const SizedBox(height: 16),

              // Menu Button 3: Logout
              _buildMenuButton(
                context: context,
                icon: Icons.output_rounded,
                label: 'Logout',
                backgroundColor: AppColors.logoutTileBg,
                borderColor: AppColors.logoutTileBorder,
                iconColor: AppColors.logoutIconColor,
                textColor: AppColors.logoutIconColor,
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  if (onLogoutTap != null) {
                    onLogoutTap!();
                  } else {
                    // Default logout behavior (Back to Login Screen)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom Styled Menu Button Container
  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color borderColor,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: iconColor,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}