import 'package:flutter/material.dart';

class PremiumSubScreenHeader extends StatelessWidget {
  final String title;
  final String illustrationPath;
  final Widget? bottomWidget;
  final double height;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const PremiumSubScreenHeader({
    Key? key,
    required this.title,
    required this.illustrationPath,
    this.bottomWidget,
    this.height = 240,
    this.showBackButton = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF083866), Color(0xFF2376F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x402376F6),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),

          // 2. Decorative Circles (Subtle)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // 3. Illustration
          Positioned(
            right: -40, // Pushed further right
            bottom: bottomWidget != null ? 30 : 0, // Lowered slightly
            height: height * 0.85, 
            child: Image.asset(
              illustrationPath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),

          // 4. Content (Back, Title, Avatar)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Back Button (Left) -- Avatar (Right)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (showBackButton)
                        GestureDetector(
                          onTap: onBackPressed ?? () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration( // White circular button
                              color: Colors.white, 
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,2))],
                            ),    
                            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2376F6), size: 20),
                          ),
                        )
                      else
                        const SizedBox(width: 40), // Placeholder

                      // Avatar
                      GestureDetector(
                         onTap: () => Navigator.pushNamed(context, '/mi_perfil'),
                         child: Container(
                           padding: const EdgeInsets.all(2),
                           decoration: BoxDecoration(
                             color: Colors.white.withOpacity(0.2),
                             shape: BoxShape.circle,
                           ),
                           child: const CircleAvatar(
                             backgroundColor: Colors.white,
                             radius: 18,
                             child: Icon(Icons.person, color: Color(0xFF2376F6), size: 20),
                           ),
                         ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Title Layout
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  
                  if (bottomWidget != null) const SizedBox(height: 50), 
                  if (bottomWidget == null) const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 5. Bottom Widget (e.g., Search Bar)
          if (bottomWidget != null)
            Positioned(
              bottom: 0,
              left: 24,
              right: 24,
              height: 56,
              child: bottomWidget!,
            ),
        ],
      ),
    );
  }
}
