import 'models/produit_conseil_model.dart';
import 'models/profil_capillaire_model.dart';
import 'models/recommandation_capillaire_model.dart';

class RecommandationMockData {
  static const ProfilCapillaireModel mockProfilCapillaire = ProfilCapillaireModel(
    id: 1,
    compteId: 42,
    nomClient: 'Diallo',
    prenomClient: 'Aïcha',
    typeCheveux: 'CREPUS',
    texture: 'EPAIS',
    porosite: 'FORTE',
    longueur: 'MI_LONGS',
    densite: 'FORTE',
    cuirChevelu: 'SEC',
    etatCheveux: 'SEC',
    hasCodeProfil: true,
  );

  static const ProduitConseilModel mockProduitLavage = ProduitConseilModel(
    id: 101,
    nom: 'Shampoing Crème Hydratant Intense',
    marque: 'Kérastase Curl Manifesto',
    description:
        'Shampoing doux sans sulfates formulé avec du miel de Manuka et du céramide pour nettoyer en douceur les cheveux crépus et bouclés tout en préservant les huiles naturelles du cuir chevelu.',
    modeUtilisation:
        'Mouiller abondamment la chevelure. Répartir une noix de shampoing sur le cuir chevelu, masser par mouvements circulaires pendant 2 minutes pour stimuler la microcirculation, puis rincer à l\'eau tiède.',
    imageUrl: 'assets/images/details_d_un_produit_img_0.png',
    etapeRoutine: 'LAVAGE',
    cuirsChevelusCibles: ['SEC', 'NORMAL', 'SENSIBLE'],
    etatsCheveuxCibles: ['SEC', 'ABIME', 'CASSE', 'TRANSITION'],
    porositesCibles: ['MOYENNE', 'FORTE'],
    typesCheveuxCibles: ['BOUCLES', 'FRISES', 'CREPUS'],
    texturesCibles: ['MOYENS', 'EPAIS'],
    scoreAffinite: 97,
  );

  static const ProduitConseilModel mockProduitSoinProfond = ProduitConseilModel(
    id: 102,
    nom: 'Masque Beurre Réparateur & Fortifiant',
    marque: 'Shea Moisture Raw Shea Butter',
    description:
        'Soin profond ultra-nourrissant à base de beurre de karité biologique, d\'huile d\'argan et de varech pour restaurer l\'élasticité et réparer en profondeur la fibre capillaire fragilisée.',
    modeUtilisation:
        'Séparer les cheveux en 4 sections après le lavage. Appliquer généreusement des demi-longueurs jusqu\'aux pointes. Laisser poser 20 à 30 minutes sous un bonnet chauffant ou une serviette tiède, puis rincer abondamment.',
    imageUrl: 'assets/images/details_d_un_produit_img_1.png',
    etapeRoutine: 'SOIN_PROFOND',
    cuirsChevelusCibles: ['SEC', 'NORMAL'],
    etatsCheveuxCibles: ['SEC', 'ABIME', 'CASSE', 'DEFRISE'],
    porositesCibles: ['FORTE'],
    typesCheveuxCibles: ['FRISES', 'CREPUS'],
    texturesCibles: ['EPAIS'],
    scoreAffinite: 96,
  );

  static const ProduitConseilModel mockProduitHydratation = ProduitConseilModel(
    id: 103,
    nom: 'Lait Capillaire Hydratant Quotidien',
    marque: 'Cantu Shea Butter Leave-In',
    description:
        'Crème revitalisante sans rinçage qui infuse une hydratation continue aux boucles et aux textures afro, facilite le démêlage et scelle les cuticules pour lutter contre les frisottis.',
    modeUtilisation:
        'Appliquer quotidiennement ou tous les 2 jours sur cheveux humides ou légèrement vaporisés d\'eau florale. Travailler mèche par mèche aux doigts pour bien définir le motif naturel du cheveu.',
    imageUrl: 'assets/images/details_d_un_produit_img_2.png',
    etapeRoutine: 'HYDRATATION',
    cuirsChevelusCibles: ['NORMAL', 'SEC', 'SENSIBLE'],
    etatsCheveuxCibles: ['SAIN', 'SEC', 'ABIME', 'TRANSITION'],
    porositesCibles: ['FAIBLE', 'MOYENNE', 'FORTE'],
    typesCheveuxCibles: ['BOUCLES', 'FRISES', 'CREPUS'],
    texturesCibles: ['FINS', 'MOYENS', 'EPAIS'],
    scoreAffinite: 94,
  );

  static const ProduitConseilModel mockProduitFinition = ProduitConseilModel(
    id: 104,
    nom: 'Huile Protectrice de Scellage & Brillance',
    marque: 'Olaplex No. 7 Bonding Oil',
    description:
        'Huile de finition légère et hautement concentrée qui scelle l\'hydratation, protège contre les agressions thermiques et extérieures, tout en apportant une brillance soyeuse sans alourdir.',
    modeUtilisation:
        'Verser 2 à 3 gouttes au creux de la paume, frotter les mains puis lisser sur les pointes et longueurs pour sceller l\'hydratation apportée par la crème.',
    imageUrl: 'assets/images/les_produits_d_une_categorie_img_0.png',
    etapeRoutine: 'FINITION',
    cuirsChevelusCibles: ['NORMAL', 'SEC', 'GRAS', 'SENSIBLE', 'PELLICULES'],
    etatsCheveuxCibles: ['SAIN', 'SEC', 'ABIME', 'CASSE', 'COLORE'],
    porositesCibles: ['FAIBLE', 'MOYENNE', 'FORTE'],
    typesCheveuxCibles: ['LISSES', 'ONDULES', 'BOUCLES', 'FRISES', 'CREPUS'],
    texturesCibles: ['FINS', 'MOYENS', 'EPAIS'],
    scoreAffinite: 93,
  );

  static final RecommandationCapillaireModel mockDerniereRecommandation =
      RecommandationCapillaireModel(
    id: 201,
    reference: 'REC-2026-F982A1B',
    dateRecommandation: DateTime.now().subtract(const Duration(days: 3)),
    typeCheveux: 'CREPUS',
    texture: 'EPAIS',
    porosite: 'FORTE',
    longueur: 'MI_LONGS',
    densite: 'FORTE',
    cuirChevelu: 'SEC',
    etatCheveux: 'SEC',
    produitLavage: mockProduitLavage,
    produitSoinProfond: mockProduitSoinProfond,
    produitHydratation: mockProduitHydratation,
    produitFinition: mockProduitFinition,
    scoreLavage: 97,
    scoreSoinProfond: 96,
    scoreHydratation: 94,
    scoreFinition: 93,
    scoreGlobal: 95,
    conseilsPersonnalises:
        'Vos cheveux crépus à forte porosité absorbent l\'eau rapidement mais peinent à la retenir. '
        'La méthode L.C.O (Liquid/Lait, Cream, Oil) est idéale pour votre profil. '
        'Espacez les shampoings (tous les 7 à 10 jours) et privilégiez les coiffures protectrices non serrées pour limiter la casse.',
    joursRestantsAvantProchainDiagnostic: 27,
  );

  static final List<RecommandationCapillaireModel> mockHistorique = [
    mockDerniereRecommandation,
    RecommandationCapillaireModel(
      id: 180,
      reference: 'REC-2026-C441E9D',
      dateRecommandation: DateTime.now().subtract(const Duration(days: 38)),
      typeCheveux: 'CREPUS',
      texture: 'EPAIS',
      porosite: 'FORTE',
      longueur: 'COURTS',
      densite: 'FORTE',
      cuirChevelu: 'SEC',
      etatCheveux: 'ABIME',
      produitLavage: mockProduitLavage,
      produitSoinProfond: mockProduitSoinProfond,
      produitHydratation: mockProduitHydratation,
      produitFinition: mockProduitFinition,
      scoreLavage: 92,
      scoreSoinProfond: 95,
      scoreHydratation: 91,
      scoreFinition: 90,
      scoreGlobal: 92,
      conseilsPersonnalises:
          'Phase de transition et de revitalisation suite à un séchage excessif. Priorisez les bains d\'huile tiède avant shampoing.',
      joursRestantsAvantProchainDiagnostic: 0,
    ),
    RecommandationCapillaireModel(
      id: 150,
      reference: 'REC-2025-A109B32',
      dateRecommandation: DateTime.now().subtract(const Duration(days: 75)),
      typeCheveux: 'FRISES',
      texture: 'MOYENS',
      porosite: 'MOYENNE',
      longueur: 'COURTS',
      densite: 'MOYENNE',
      cuirChevelu: 'NORMAL',
      etatCheveux: 'SAIN',
      produitLavage: mockProduitLavage,
      produitSoinProfond: mockProduitSoinProfond,
      produitHydratation: mockProduitHydratation,
      produitFinition: mockProduitFinition,
      scoreLavage: 89,
      scoreSoinProfond: 90,
      scoreHydratation: 88,
      scoreFinition: 87,
      scoreGlobal: 89,
      conseilsPersonnalises:
          'Routine d\'entretien régulier. Vos cheveux sont équilibrés, maintenez l\'hydratation avec des produits sans alcool desséchant.',
      joursRestantsAvantProchainDiagnostic: 0,
    ),
  ];
}
