enum StatutCommande {
  enAttente('EN_ATTENTE', 'En attente'),
  validee('VALIDEE', 'Validée'),
  recuperee('RECUPEREE', 'Récupérée'),
  rejette('REJETEE', 'Rejetée'),
  annulee('ANNULEE', 'Annulée');

  final String code;
  final String label;

  const StatutCommande(this.code, this.label);

  static StatutCommande fromString(String? val) {
    if (val == null) return StatutCommande.enAttente;
    final upper = val.toUpperCase();
    if (upper.contains('VALID') || upper == 'VALIDEE') return StatutCommande.validee;
    if (upper.contains('RECUP') || upper == 'RECUPEREE' || upper == 'LIVREE') return StatutCommande.recuperee;
    if (upper.contains('REJET') || upper == 'REJETEE') return StatutCommande.rejette;
    if (upper.contains('ANNUL') || upper == 'ANNULEE') return StatutCommande.annulee;
    return StatutCommande.enAttente;
  }
}

class LigneCommandeModel {
  final int id;
  final int produitId;
  final String produitNom;
  final int quantite;
  final double prixUnitaire;
  final double sousTotal;
  final String imagePath;

  const LigneCommandeModel({
    required this.id,
    required this.produitId,
    required this.produitNom,
    required this.quantite,
    required this.prixUnitaire,
    required this.sousTotal,
    required this.imagePath,
  });

  factory LigneCommandeModel.fromJson(Map<String, dynamic> json) {
    final qte = (json['quantite'] as num?)?.toInt() ?? 1;
    final pu = (json['prixUnitaire'] as num?)?.toDouble() ?? 0.0;
    final st = (json['sousTotal'] as num?)?.toDouble() ?? (pu * qte);

    return LigneCommandeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      produitId: (json['produitId'] as num?)?.toInt() ?? 0,
      produitNom: json['produitNom'] as String? ?? 'Produit cosmétique',
      quantite: qte,
      prixUnitaire: pu,
      sousTotal: st,
      imagePath: json['imagePath'] as String? ?? 'assets/images/cmd_list_0.png',
    );
  }
}

class CommandeModel {
  final int id;
  final String numeroCommande;
  final DateTime dateCommande;
  final StatutCommande statut;
  final double montantTotal;
  final double sousTotal;
  final double fraisLivraison;
  final String modePaiement;
  final String clientNom;
  final String clientTelephone;
  final String adresseLivraison;
  final String? codeRetrait;
  final String? motifRejet;
  final String? traiteParNom;
  final int? factureId;
  final String? numeroFacture;
  final List<LigneCommandeModel> lignes;

  const CommandeModel({
    required this.id,
    required this.numeroCommande,
    required this.dateCommande,
    required this.statut,
    required this.montantTotal,
    required this.sousTotal,
    required this.fraisLivraison,
    this.modePaiement = 'Paiement à la livraison / Wave',
    this.clientNom = 'Aïcha Diallo',
    this.clientTelephone = '+221 77 123 45 67',
    this.adresseLivraison = 'Almadies, près de la pharmacie du rond-point',
    this.codeRetrait,
    this.motifRejet,
    this.traiteParNom,
    this.factureId,
    this.numeroFacture,
    required this.lignes,
  });

  factory CommandeModel.fromJson(Map<String, dynamic> json) {
    final rawLignes = json['lignes'] as List<dynamic>? ?? [];
    final lignes = rawLignes
        .map((e) => LigneCommandeModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final total = (json['montantTotal'] as num?)?.toDouble() ?? 25000.0;
    const frais = 2500.0;
    final sousTot = (total - frais > 0) ? (total - frais) : total;

    return CommandeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      numeroCommande: json['numeroCommande'] as String? ?? '#COM-2026-0048',
      dateCommande: json['dateCommande'] != null
          ? DateTime.tryParse(json['dateCommande'].toString()) ?? DateTime.now()
          : DateTime.now(),
      statut: StatutCommande.fromString(json['statut'] as String?),
      montantTotal: total,
      sousTotal: sousTot,
      fraisLivraison: frais,
      modePaiement: json['modePaiement'] as String? ?? 'Wave',
      clientNom: json['clientNom'] as String? ?? 'Aïcha Diallo',
      clientTelephone: json['clientTelephone'] as String? ?? '+221 77 123 45 67',
      adresseLivraison: json['adresseLivraison'] as String? ??
          'Almadies, près de la pharmacie du rond-point',
      codeRetrait: json['codeRetrait'] as String?,
      motifRejet: json['motifRejet'] as String?,
      traiteParNom: json['traiteParNom'] as String?,
      factureId: (json['factureId'] as num?)?.toInt(),
      numeroFacture: json['numeroFacture'] as String?,
      lignes: lignes,
    );
  }
}
