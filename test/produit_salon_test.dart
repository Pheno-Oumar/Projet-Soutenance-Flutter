import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hair_style/features/panier/data/models/panier_model.dart';
import 'package:mobile_hair_style/features/panier/presentation/providers/panier_provider.dart';
import 'package:mobile_hair_style/features/salon/data/models/produit_salon_model.dart';

void main() {
  group('ProduitSalonModel, CategorieProduitModel & Multi-Salon Cart Models Lot 2 Tests', () {
    test('StockProduitModel fromJson and properties', () {
      final json = {
        'id': 1,
        'quantiteDisponible': 15,
        'seuilMinimum': 5,
        'seuilMaximum': 50,
        'alerteStockBas': false,
        'dateDerniereMiseAJour': '2026-10-17T18:00:00Z',
      };

      final stock = StockProduitModel.fromJson(json);

      expect(stock.id, 1);
      expect(stock.quantiteDisponible, 15);
      expect(stock.seuilMinimum, 5);
      expect(stock.seuilMaximum, 50);
      expect(stock.alerteStockBas, false);
      expect(stock.dateDerniereMiseAJour, isNotNull);
    });

    test('ProduitSalonModel fromJson with stock and mainImage', () {
      final json = {
        'id': 42,
        'nom': 'Huile de Ricin Pure',
        'description': 'Huile fortifiante et stimulante pour la pousse',
        'prixVente': 4500.0,
        'imageUrl': 'https://res.cloudinary.com/test/ricin.jpg',
        'imagesUrls': [
          'https://res.cloudinary.com/test/ricin.jpg',
          'https://res.cloudinary.com/test/ricin_back.jpg'
        ],
        'statut': true,
        'categorieId': 3,
        'categorieNom': 'Soins Capillaires',
        'stock': {
          'id': 8,
          'quantiteDisponible': 12,
          'seuilMinimum': 3,
        },
      };

      final produit = ProduitSalonModel.fromJson(json);

      expect(produit.id, 42);
      expect(produit.nom, 'Huile de Ricin Pure');
      expect(produit.prixVente, 4500.0);
      expect(produit.mainImage, 'https://res.cloudinary.com/test/ricin.jpg');
      expect(produit.imagesUrls.length, 2);
      expect(produit.categorieNom, 'Soins Capillaires');
      expect(produit.quantiteEnStock, 12);
      expect(produit.isEnRupture, false);
    });

    test('ProduitSalonModel detects rupture when stock is 0', () {
      final json = {
        'id': 43,
        'nom': 'Masque Argan Épuisé',
        'prixVente': 7000.0,
        'stock': {
          'id': 9,
          'quantiteDisponible': 0,
        },
      };

      final produit = ProduitSalonModel.fromJson(json);

      expect(produit.quantiteEnStock, 0);
      expect(produit.isEnRupture, true);
    });

    test('CategorieProduitModel parses nested products correctly', () {
      final json = {
        'id': 5,
        'nom': 'Shampoings & Après-Shampoings',
        'description': 'Soins lavants adaptés à tout type de cheveux',
        'imageUrl': 'https://res.cloudinary.com/test/cat5.jpg',
        'statut': true,
        'salonSlug': 'beauty-by-dika',
        'nombreProduits': 2,
        'produits': [
          {
            'id': 101,
            'nom': 'Shampoing Clarifiant',
            'prixVente': 3500.0,
            'stock': {'id': 1, 'quantiteDisponible': 4},
          },
          {
            'id': 102,
            'nom': 'Après-Shampoing Démêlant',
            'prixVente': 4000.0,
            'stock': {'id': 2, 'quantiteDisponible': 6},
          },
        ],
      };

      final cat = CategorieProduitModel.fromJson(json);

      expect(cat.id, 5);
      expect(cat.nom, 'Shampoings & Après-Shampoings');
      expect(cat.nombreProduits, 2);
      expect(cat.produits.length, 2);
      expect(cat.produits.first.nom, 'Shampoing Clarifiant');
      expect(cat.produits.first.prixVente, 3500.0);
    });

    test('Multi-salon cart models PanierModel & LignePanierModel compute totals', () {
      const ligne1 = LignePanierModel(
        id: 1,
        produitId: 101,
        produitNom: 'Shampoing',
        prixUnitaire: 3500.0,
        quantite: 2,
        sousTotal: 7000.0,
        stockDisponible: 10,
      );

      const ligne2 = LignePanierModel(
        id: 2,
        produitId: 102,
        produitNom: 'Masque',
        prixUnitaire: 5000.0,
        quantite: 1,
        sousTotal: 5000.0,
        stockDisponible: 5,
      );

      const panier = PanierModel(
        id: 1,
        slugSalon: 'beauty-by-dika',
        salonNom: 'Beauty By Dika',
        lignes: [ligne1, ligne2],
        montantTotal: 12000.0,
        nombreArticles: 3,
      );

      expect(panier.slugSalon, 'beauty-by-dika');
      expect(panier.salonNom, 'Beauty By Dika');
      expect(panier.nombreArticles, 3);
      expect(panier.montantTotal, 12000.0);
      expect(panier.lignes.length, 2);
    });

    test('PanierState tracks validating state and per-salon slug correctly', () {
      const ligne = LignePanierModel(
        id: 1,
        produitId: 101,
        produitNom: 'Shampoing',
        prixUnitaire: 3500.0,
        quantite: 2,
        sousTotal: 7000.0,
        stockDisponible: 10,
      );
      const panier = PanierModel(
        id: 1,
        slugSalon: 'salon-chic',
        salonNom: 'Salon Chic',
        lignes: [ligne],
        montantTotal: 7000.0,
        nombreArticles: 2,
      );

      final state = PanierState(paniers: [panier]);
      expect(state.totalArticles, 2);
      expect(state.montantTotalGlobal, 7000.0);
      expect(state.isValidating, false);
      expect(state.validatingSalonSlug, isNull);

      final validatingState = state.copyWith(
        isValidating: true,
        validatingSalonSlug: 'salon-chic',
      );
      expect(validatingState.isValidating, true);
      expect(validatingState.validatingSalonSlug, 'salon-chic');

      final clearedState = validatingState.copyWith(
        isValidating: false,
        clearValidatingSlug: true,
      );
      expect(clearedState.isValidating, false);
      expect(clearedState.validatingSalonSlug, isNull);
    });
  });
}
