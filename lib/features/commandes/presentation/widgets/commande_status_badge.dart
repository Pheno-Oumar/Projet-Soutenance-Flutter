import 'package:flutter/material.dart';
import '../../data/models/commande_model.dart';

class CommandeStatusBadge extends StatelessWidget {
  final StatutCommande statut;

  const CommandeStatusBadge({
    super.key,
    required this.statut,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    String label;

    switch (statut) {
      case StatutCommande.validee:
        bg = const Color(0xFF0E4429); // Vert sombre de la maquette
        textColor = Colors.white;
        label = 'Validée';
        break;
      case StatutCommande.recuperee:
        bg = const Color(0xFF073832); // Vert canard foncé de la maquette
        textColor = Colors.white;
        label = 'Récupérée';
        break;
      case StatutCommande.enAttente:
        bg = const Color(0xFFA0A0A0); // Gris neutre de la maquette
        textColor = Colors.white;
        label = 'En attente';
        break;
      case StatutCommande.rejette:
        bg = const Color(0xFFF87171); // Rouge pastel de la maquette
        textColor = Colors.white;
        label = 'Rejetée';
        break;
      case StatutCommande.annulee:
        bg = const Color(0xFFFAD4D8); // Rose/Rouge doux de la maquette
        textColor = const Color(0xFFE53935);
        label = 'Annulée';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
