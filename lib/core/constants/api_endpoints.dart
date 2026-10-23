class ApiEndpoints {
  // Base URLs
  // Pour émulateur Android : http://10.0.2.2:8080/api/v1/mon-salon
  // Pour web/desktop : http://localhost:8080/api/v1/mon-salon
  // Pour appareil physique : remplacer par l'IP locale (ex: http://192.168.1.X:8080/api/v1/mon-salon)
  static const String defaultBaseUrl = 'http://10.0.2.2:8080/api/v1/mon-salon';

  // 1. Authentification
  static const String login = '/auth/login';
  static const String register = '/client/register';
  static const String refreshToken = '/auth/refresh-token';

  // 2. Exploration Visiteur & Salons
  static const String salons = '/explore/salons';
  static const String salonSearch = '/explore/salons/search';
  static const String salonNearby = '/explore/salons/nearby';
  static const String salonParService = '/explore/salons/par-service';
  static String salonDetail(String slug) => '/explore/salons/$slug';
  static String salonServices(String slug) => '/explore/salons/$slug/services';
  static String salonServiceDetail(String slug, int id) => '/explore/salons/$slug/services/$id';
  static String salonServiceVariantes(String slug, int id) => '/explore/salons/$slug/services/$id/variantes';
  static String salonCategoriesProduits(String slug) => '/explore/salons/$slug/categories-produits';
  static String salonCategorieProduitDetail(String slug, int id) => '/explore/salons/$slug/categories-produits/$id';
  static String salonProduits(String slug) => '/explore/salons/$slug/produits';
  static String salonProduitDetail(String slug, int id) => '/explore/salons/$slug/produits/$id';
  static String salonAvis(String slug) => '/explore/salons/$slug/avis';
  static String salonRealisations(String slug) => '/explore/salons/$slug/realisations';
  static String salonDisponibilites(String slug) => '/explore/salons/$slug/disponibilites';
  static String salonCoiffeurs(String slug) => '/explore/salons/$slug/coiffeurs';
  static String salonHoraires(String slug) => '/explore/salons/$slug/horaires';
  static String salonStories(String slug) => '/$slug/vitrine/stories';

  // Services, Produits & Réalisations transversales
  static const String servicesTransversal = '/explore/services';
  static const String produitsTransversal = '/explore/produits';
  static String produitDetail(int id) => '/explore/produits/$id';
  static String produitAvis(int id) => '/explore/produits/$id/avis';
  static const String realisationsTransversal = '/explore/realisations';

  // 3. Kady's (Flux vidéo TikTok)
  static const String kadysFeed = '/kadys/feed';
  static String kadysDetail(int id) => '/kadys/$id';
  static String kadysVue(int id) => '/kadys/$id/vue';
  static String kadysLike(int id) => '/kadys/$id/like';
  static String kadysCommentaires(int id) => '/kadys/$id/commentaires';
  static String kadysSupprimerCommentaire(int id) => '/kadys/commentaires/$id';
  static const String kadysStories = '/kadys/stories';
  static const String clientInspirations = '/client/inspirations';

  // 4. Espace Client : Favoris
  static const String favorisSalons = '/client/favoris/salons';
  static String favoriSalonToggle(String slug) => '/client/favoris/salons/$slug';
  static const String favorisCoiffures = '/client/favoris/coiffures';
  static String favoriCoiffureToggle(int varianteId) => '/client/favoris/coiffures/$varianteId';
  static const String favorisProduits = '/client/favoris/produits';
  static String favoriProduitToggle(int produitId) => '/client/favoris/produits/$produitId';

  // 5. Espace Client : Rendez-vous & Prestations
  static const String clientRendezVous = '/client/rendez-vous';
  static String clientRendezVousDetail(int id) => '/client/rendez-vous/$id';
  static String clientRendezVousAnnuler(int id) => '/client/rendez-vous/$id/annuler';
  static const String clientPrestations = '/client/prestations';
  static String clientPrestationDetail(int id) => '/client/prestations/$id';

  // Avis Client
  static const String clientAvisSalons = '/client/avis/salons';
  static const String clientAvisPrestations = '/client/avis/prestations';
  static const String clientAvisProduits = '/client/avis/produits';

  // 6. Espace Client : Panier & Commandes
  static const String clientPanier = '/client/panier';
  static const String clientPaniers = '/client/paniers';
  static const String clientPaniersViderTous = '/client/paniers';
  static String salonPanier(String slug) => '/$slug/client/panier';
  static String salonPanierArticles(String slug) => '/$slug/client/panier/articles';
  static String salonPanierArticle(String slug, int produitId) => '/$slug/client/panier/articles/$produitId';
  static const String clientPanierAjouter = '/client/panier/articles';
  static String clientPanierModifierQte(int id) => '/client/panier/articles/$id';
  static String clientPanierSupprimer(int id) => '/client/panier/articles/$id';
  static const String clientPanierVider = '/client/panier/vider';
  static const String clientCommandes = '/client/commandes';
  static String salonCommande(String slug) => '/$slug/client/commandes';
  static String salonVitrineCommande(String slug) => '/$slug/vitrine/commandes';
  static String salonVitrineRendezVous(String slug) => '/$slug/vitrine/rendez-vous';
  static String salonClientRendezVous(String slug) => '/$slug/client/rendez-vous';
  static String clientCommandeDetail(int id) => '/client/commandes/$id';

  // 7. Espace Client : Notifications
  static const String clientNotifications = '/client/notifications';
  static const String clientNotificationsNonLuesCount = '/client/notifications/non-lues/count';
  static String clientNotificationLire(int id) => '/client/notifications/$id/lire';
  static const String clientNotificationsToutLire = '/client/notifications/tout-lire';
  static String clientNotificationSupprimer(int id) => '/client/notifications/$id';

  // 8. Espace Client : Profil Capillaire & Diagnostics
  static const String clientProfilCapillaire = '/client/profil-capillaire';
  static const String clientProfilCapillaireCode = '/client/profil-capillaire/code';
  static const String clientRecommandationGenerer = '/client/recommandations-capillaires/generer';
  static const String clientRecommandationDerniere = '/client/recommandations-capillaires/derniere';
  static const String clientRecommandationHistorique = '/client/recommandations-capillaires/historique';
  static String clientRecommandationDetail(int id) => '/client/recommandations-capillaires/$id';

  // 9. Espace Client : Avis & Réclamations
  static const String clientAvisSalon = '/client/avis/salons';
  static const String clientAvisProduit = '/client/avis/produits';
  static String clientAvisProduitDetail(int id) => '/client/avis/produits/$id';
  static const String clientReclamations = '/client/reclamations';
  static String clientReclamationDetail(int id) => '/client/reclamations/$id';

  // 10. Assistant Virtuel Gemini IA
  static const String assistantChat = '/assistant/chat';
  static const String clientAssistanceGemini = '/client/assistance-gemini';
  static String assistantConfirmerAction(String id) => '/assistant/actions/$id/confirmer';
  static String assistantAnnulerAction(String id) => '/assistant/actions/$id/annuler';

  // 11. Compte & Sécurité
  static const String clientCompte = '/client/compte';
  static const String clientChangementMotDePasse = '/client/compte/mot-de-passe';

  // 12. Favoris (Salons, Coiffures, Produits)
  static const String clientFavorisSalons = '/client/favoris/salons';
  static const String clientFavorisCoiffures = '/client/favoris/coiffures';
  static const String clientFavorisProduits = '/client/favoris/produits';
  static String clientFavoriSalonToggle(String slug) => '/client/favoris/$slug';
  static String clientFavoriCoiffureToggle(int id) => '/client/favoris/coiffures/$id';
  static String clientFavoriProduitToggle(int id) => '/client/favoris/produits/$id';
}
