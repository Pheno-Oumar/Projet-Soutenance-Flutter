class AstuceNaturelleModel {
  final String titre;
  final String sousTitre;
  final String type;
  final String ingredients;
  final String preparation;
  final String benefice;

  const AstuceNaturelleModel({
    required this.titre,
    required this.sousTitre,
    required this.type,
    required this.ingredients,
    required this.preparation,
    required this.benefice,
  });

  static const List<AstuceNaturelleModel> astucesParDefaut = [
    AstuceNaturelleModel(
      titre: 'Bain d\'huile tiède nourrissant',
      sousTitre: 'Avant-shampoing assouplissant & anti-casse',
      type: 'Petit Budget',
      ingredients: '3 c. à soupe d\'huile d\'olive ou de coco pure (disponible partout)',
      preparation:
          'Chauffer légèrement l\'huile au bain-marie (tiède, jamais brûlante). Appliquer sur les longueurs et pointes 30 minutes avant le lavage sous serviette tiède.',
      benefice: 'Protège la fibre avant le lavage et évite l\'effet paille causé par l\'eau calcaire.',
    ),
    AstuceNaturelleModel(
      titre: 'Masque Gourmand Avocat & Banane',
      sousTitre: 'Soin profond 100% naturel fait maison',
      type: '0 FCFA • Cuisine',
      ingredients: '1 demi-avocat bien mûr + 1 banane mûre + 1 c. à café de miel ou yaourt',
      preparation:
          'Écraser ou mixer très finement pour éviter les grumeaux. Appliquer mèche par mèche après le shampoing, laisser agir 20 minutes sous une charlotte, puis rincer.',
      benefice: 'Apporte une nutrition intense et une brillance immédiate sans aucun produit chimique.',
    ),
    AstuceNaturelleModel(
      titre: 'Lotion Fortifiante à l\'Eau de Riz',
      sousTitre: 'Rituel millénaire pour stimuler la pousse',
      type: '100% Gratuit (0 FCFA)',
      ingredients: 'Eau de rinçage ou de cuisson du riz blanc ou complet (non salée)',
      preparation:
          'Récupérer l\'eau trouble après avoir rincé votre riz. Laisser reposer 12h à température ambiante, puis verser sur vos cheveux comme dernière eau de rinçage.',
      benefice: 'Riche en inositol et acides aminés, renforce la racine et referme les écailles.',
    ),
    AstuceNaturelleModel(
      titre: 'Scellage au Beurre de Karité Brut',
      sousTitre: 'Le protecteur souverain naturel',
      type: 'Accessible & Local',
      ingredients: 'Une petite noisette de beurre de karité pur non raffiné',
      preparation:
          'Frotter la noisette entre vos paumes jusqu\'à ce qu\'elle devienne huileuse. Lisser délicatement sur vos pointes humides pour bloquer l\'eau à l\'intérieur.',
      benefice: 'Crée un bouclier imperméable naturel qui retient l\'hydratation jusqu\'à 5 jours.',
    ),
    AstuceNaturelleModel(
      titre: 'Protection nocturne au foulard satin',
      sousTitre: 'Le geste zéro dépense anti-frottement',
      type: 'Habitude Gratuite',
      ingredients: 'Un foulard en satin ou un bonnet doux pour dormir',
      preparation:
          'Envelopper vos cheveux chaque soir avant de dormir. Éviter le contact direct avec l\'oreiller en coton qui déshydrate la chevelure.',
      benefice: 'Élimine 80% des frisottis et de la casse au réveil.',
    ),
  ];
}
