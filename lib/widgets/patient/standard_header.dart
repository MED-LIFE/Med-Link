import 'package:flutter/material.dart';
import 'dart:ui';
import '../../services/notification_service.dart';

class StandardPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isLarge; // For larger banners like Home/Historia
  final double imageScale;
  final double imageRightOffset;
  final Widget? trailing; // Add this

  const StandardPageHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.isLarge = false,
    this.imageScale = 1.0,
    this.imageRightOffset = -20.0,
    this.trailing, // Add this
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: isLarge ? 232 : 200, // 232 same as Home, 200 for others (increased from 180 to avoid overflow)
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Color (Matches Scaffold usually, but can be forced if needed)
          Positioned.fill(
             child: Container(color: const Color(0xFFFEF9F1)), // Matching Home Base
          ),
          
          // ILLUSTRATION
          Positioned(
            right: imageRightOffset, 
            bottom: isLarge ? -72 : -30, // Adjusted bottom to pull it up slightly or keep checks
            height: (isLarge ? 280 : 160) * imageScale, // Reduced from 330/220 to 280/160
            child: Image.asset(
              imagePath, 
              fit: BoxFit.contain, 
            ),
          ),

          // Notification Icon
          Positioned(
            top: 40,
            right: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailing != null) ...[
                  trailing!,
                  const SizedBox(width: 8),
                ],
                NotificationBadge(
                  child: GestureDetector(
                    onTap: () => _showNotificationsDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                      ),
                      child: const Icon(Icons.notifications_outlined, color: Color(0xFF083866), size: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
            
          // TEXT CONTENT
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 16), // 24 side Padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Back Button if not root (Optional, usually handled by AppBar but here we might need custom)
                   if (Navigator.canPop(context))
                     Padding(
                       padding: const EdgeInsets.only(bottom: 16),
                       child: GestureDetector(
                         onTap: () => Navigator.pop(context),
                         child: Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.circular(12),
                             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                           ),
                           child: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: Color(0xFF2376F6)),
                         ),
                       ),
                     ),

                  Text(
                    title, 
                    style: const TextStyle(
                      fontSize: 26, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF083866),
                      letterSpacing: -0.5
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.w600, 
                      color: Color(0xFF2376F6)
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               const Icon(Icons.notifications_active_rounded, color: Color(0xFF2376F6), size: 40),
               const SizedBox(height: 16),
               const Text("Notificaciones", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               const SizedBox(height: 8),
               const Text("No tienes notificaciones nuevas.", style: TextStyle(color: Colors.grey)),
               const SizedBox(height: 24),
               TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar"))
            ],
          ),
        ),
      ),
    );
  }
}
