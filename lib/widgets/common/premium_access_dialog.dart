import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bouncing_card.dart';

class PremiumAccessHelper {
  static bool canAccessFeature() {
    final user = FirebaseAuth.instance.currentUser;
    // 3. GOD MODE / ADMIN BYPASS
    // Allows us to test premium features without paying
    final email = user?.email ?? "";
    if (email.startsWith("medico") || email.startsWith("admin")) {
      return true;
    }return false;
  }

  static void showPremiumDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // GLOW EFFECT
            Container(
              height: 420,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Color(0x662376F6), blurRadius: 60, spreadRadius: 10),
                ]
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1C2E), // Dark Platinum Theme
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2376F6).withOpacity(0.5), width: 1.5),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D1C2E), Color(0xFF152642)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ICON
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2376F6),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Color(0xFF2376F6), blurRadius: 20, spreadRadius: 0)],
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 24),

                  // TEXT
                  Text(
                    "Función Premium".toUpperCase(),
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold, 
                      color: const Color(0xFF2376F6).withOpacity(0.8), 
                      letterSpacing: 1.5
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    featureName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    "Accedé a la tecnología de vanguardia de Zanoo Platinum. \nVideo Consultas HD, Prioridad en Turnos y Reportes Avanzados.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, height: 1.5, fontSize: 14),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // BUTTONS
                  SizedBox(
                    width: double.infinity,
                    child: BouncingCard(
                      onTap: () {
                         Navigator.pop(context);
                         // Here we would go to Payment Gateway
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Redirecting to MercadoPago...")));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF2376F6), Color(0xFF0055FF)]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: const Color(0xFF2376F6).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 4))],
                        ),
                        child: const Center(
                          child: Text(
                            "Mejorar Plan",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Ahora no", style: TextStyle(color: Colors.white.withOpacity(0.5))),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
