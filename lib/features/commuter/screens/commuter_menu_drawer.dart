import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CommuterMenuDrawer extends StatelessWidget {
  final String commuterName;
  final String commuterId;
  final String? photoPath;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onQrCodeTap;
  final VoidCallback? onLogoutTap;

  const CommuterMenuDrawer({
  super.key,
  this.commuterName = "Juan Dela Cruz",
  this.commuterId = "CM-0001",
  this.photoPath,
  this.onSettingsTap,
  this.onQrCodeTap,
  this.onLogoutTap,
});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      elevation: 0,
      width: MediaQuery.of(context).size.width * .78,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Profile Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFD9D9D9),
                    backgroundImage: photoPath != null
                        ? FileImage(File(photoPath!))
                        : null,
                    child: photoPath == null
                        ? const Icon(
                            Icons.person,
                            size: 36,
                            color: AppColors.textSecondary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          commuterName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 2),

                        const Text(
                          "Commuter ID:",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.logoBlue,
                          ),
                        ),

                        Text(
                          commuterId,
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

              /// Settings
              _buildMenuButton(
                context: context,
                icon: Icons.settings_suggest_rounded,
                label: "Settings",
                backgroundColor: AppColors.settingsTileBg,
                borderColor: AppColors.settingsTileBorder,
                iconColor: AppColors.settingsIconColor,
                textColor: AppColors.textPrimary,
                onTap: () {
                  Navigator.pop(context);

                  if (onSettingsTap != null) {
                    onSettingsTap!();
                  }
                },
              ),

              const SizedBox(height: 16),

              /// Logout
              _buildMenuButton(
                context: context,
                icon: Icons.output_rounded,
                label: "Logout",
                backgroundColor: AppColors.logoutTileBg,
                borderColor: AppColors.logoutTileBorder,
                iconColor: AppColors.logoutIconColor,
                textColor: AppColors.logoutIconColor,
                onTap: () {
                  Navigator.pop(context);

                  if (onLogoutTap != null) {
                    onLogoutTap!();
                  } else {
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
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