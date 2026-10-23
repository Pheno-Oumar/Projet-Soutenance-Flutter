import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/assistant/presentation/assistant_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/compte/presentation/compte_screen.dart';
import '../features/compte/presentation/modifier_profil_screen.dart';
import '../features/compte/presentation/changer_mot_de_passe_screen.dart';
import '../features/compte/presentation/mes_favoris_screen.dart';
import '../features/commandes/presentation/mes_commandes_screen.dart';
import '../features/commandes/presentation/details/commande_detail_dispatcher_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/home/presentation/recherche_screen.dart';
import '../features/kadys/presentation/kadys_feed_screen.dart';
import '../features/notification/presentation/notifications_screen.dart';
import '../features/parametres/presentation/parametres_screen.dart';
import '../features/panier/presentation/panier_screen.dart';
import '../features/reclamations/presentation/mes_reclamations_screen.dart';
import '../features/reclamations/presentation/details/reclamation_detail_screen.dart';
import '../features/reclamations/presentation/nouvelle_reclamation_screen.dart';
import '../features/reclamations/data/models/reclamation_model.dart';
import '../features/prestations/presentation/mes_prestations_screen.dart';
import '../features/prestations/presentation/details/prestation_detail_screen.dart';
import '../features/prestations/data/models/prestation_model.dart';
import '../features/rendezvous/presentation/mes_rendezvous_screen.dart';
import '../features/rendezvous/presentation/panier_rendezvous_screen.dart';
import '../features/rendezvous/presentation/details/rendezvous_detail_screen.dart';
import '../features/rendezvous/data/models/rendezvous_model.dart';
import '../features/salon/presentation/categorie_produits_screen.dart';
import '../features/salon/presentation/lire_realisation_screen.dart';
import '../features/salon/presentation/produit_detail_screen.dart';
import '../features/salon/presentation/salon_detail_screen.dart';
import '../features/salon/presentation/salon_list_screen.dart';
import '../features/salon/presentation/service_variantes_screen.dart';
import '../features/salon/presentation/story_screen.dart';
import '../features/salon/presentation/variante_detail_screen.dart';
import '../features/recommandations/data/models/produit_conseil_model.dart';
import '../features/recommandations/data/models/recommandation_capillaire_model.dart';
import '../features/recommandations/presentation/mes_recommandations_screen.dart';
import '../features/recommandations/presentation/details_recommandation_screen.dart';
import '../features/recommandations/presentation/details_produit_recommande_screen.dart';
import '../features/recommandations/presentation/historique_recommandations_screen.dart';
import '../features/recommandations/presentation/profil_capillaire_screen.dart';
import 'navigation_shell.dart';
import 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _accueilNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'accueil');
final _salonNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'salon');
final _kadysNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'kadys');
final _compteNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'compte');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.onboarding,
    routes: [
      GoRoute(
        path: RouteNames.onboarding,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Shell persistant avec BottomNavigationBar à 4 onglets
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // 1. Branche Accueil
          StatefulShellBranch(
            navigatorKey: _accueilNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // 2. Branche Salon
          StatefulShellBranch(
            navigatorKey: _salonNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.salons,
                builder: (context, state) => const SalonListScreen(),
                routes: [
                  GoRoute(
                    path: ':slug',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final slug = state.pathParameters['slug'] ?? '';
                      final tabStr = state.uri.queryParameters['tab'];
                      final initialTab = tabStr != null ? int.tryParse(tabStr) ?? 0 : 0;
                      return SalonDetailScreen(slug: slug, initialTabIndex: initialTab);
                    },
                  ),
                ],
              ),
            ],
          ),
          // 3. Branche Kady's (TikTok feed)
          StatefulShellBranch(
            navigatorKey: _kadysNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.kadys,
                builder: (context, state) => const KadysFeedScreen(),
              ),
            ],
          ),
          // 4. Branche Compte
          StatefulShellBranch(
            navigatorKey: _compteNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.compte,
                builder: (context, state) => const CompteScreen(),
              ),
            ],
          ),
        ],
      ),

      // Routes globales de l'AppBar (ouverte au-dessus du shell)
      GoRoute(
        path: RouteNames.panier,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PanierScreen(),
      ),
      GoRoute(
        path: RouteNames.panierRendezVous,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PanierRendezVousScreen(),
      ),
      GoRoute(
        path: RouteNames.mesRendezVous,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MesRendezVousScreen(),
      ),
      GoRoute(
        path: RouteNames.rendezVousDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '1';
          final id = int.tryParse(idStr) ?? 1;
          final extraRdv = state.extra is RendezVousModel ? state.extra as RendezVousModel : null;
          return RendezVousDetailScreen(id: id, initialRdv: extraRdv);
        },
      ),
      GoRoute(
        path: RouteNames.notifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RouteNames.recherche,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final query = state.uri.queryParameters['q'];
          final distStr = state.uri.queryParameters['dist'];
          final dist = distStr != null ? int.tryParse(distStr) : null;
          return RechercheScreen(initialQuery: query, initialDistance: dist);
        },
      ),

      // Routes d'authentification
      GoRoute(
        path: RouteNames.login,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Assistant Gemini IA
      GoRoute(
        path: RouteNames.assistantChat,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AssistantScreen(),
      ),

      // Visualiseur de Stories de salon (Plein écran avec barre de progression)
      GoRoute(
        path: RouteNames.story,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final salonName = state.uri.queryParameters['salon'] ?? 'Salon Beauty';
          final initials = state.uri.queryParameters['initials'] ?? 'SB';
          final slug = state.uri.queryParameters['slug'] ?? '';
          return StoryScreen(salonName: salonName, initials: initials, slug: slug);
        },
      ),

      // Les variantes d'un service
      GoRoute(
        path: RouteNames.serviceVariantes,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? 'Tresses collées';
          final desc = state.uri.queryParameters['desc'] ??
              'La tresse africaine est une coiffure traditionnelle où les cheveux sont tressés serrés et près du cuir chevelu en intégrant progressivement de nouvelles mèches.';
          final salon = state.uri.queryParameters['salon'] ?? 'Beauty By Dika';
          final slug = state.uri.queryParameters['slug'] ?? 'beauty-by-dika';
          final serviceId = int.tryParse(state.uri.queryParameters['serviceId'] ?? '');
          return ServiceVariantesScreen(
            serviceTitle: title,
            serviceDescription: desc,
            salonName: salon,
            slugSalon: slug,
            serviceId: serviceId,
          );
        },
      ),

      // Détails d'une variante
      GoRoute(
        path: RouteNames.varianteDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? 'Tresses africaine';
          final price = state.uri.queryParameters['price'] ?? '5 000 FCFA';
          final image = state.uri.queryParameters['image'] ?? 'assets/images/details_d_une_variante_img_0.png';
          final salon = state.uri.queryParameters['salon'] ?? 'Beauty By Dika';
          final slug = state.uri.queryParameters['slug'];
          final varianteId = int.tryParse(state.uri.queryParameters['varianteId'] ?? '');
          final serviceId = int.tryParse(state.uri.queryParameters['serviceId'] ?? '');
          final duree = int.tryParse(state.uri.queryParameters['duree'] ?? '');
          final description = state.uri.queryParameters['description'];
          return VarianteDetailScreen(
            title: title,
            price: price,
            image: image,
            salonName: salon,
            slugSalon: slug,
            varianteId: varianteId,
            serviceId: serviceId,
            dureeMinutes: duree,
            description: description,
          );
        },
      ),

      // Les produits d'une catégorie
      GoRoute(
        path: RouteNames.categorieProduits,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final idStr = state.uri.queryParameters['id'];
          final id = idStr != null ? int.tryParse(idStr) : null;
          final slug = state.uri.queryParameters['slug'];
          final salon = state.uri.queryParameters['salon'];
          final title = state.uri.queryParameters['title'] ?? 'Lavage';
          final desc = state.uri.queryParameters['desc'] ??
              'Le lavage consiste à nettoyer le cuir chevelu en éliminant les impuretés, l\'excès de sébum, la transpiration et les résidus de produits de coiffage.';
          return CategorieProduitsScreen(
            categorieId: id,
            slugSalon: slug,
            salonNom: salon,
            categoryTitle: title,
            categoryDescription: desc,
          );
        },
      ),

      // Détails d'un produit
      GoRoute(
        path: RouteNames.produitDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final idStr = state.uri.queryParameters['id'];
          final id = idStr != null ? int.tryParse(idStr) : null;
          final slug = state.uri.queryParameters['slug'];
          final salon = state.uri.queryParameters['salon'];
          final title = state.uri.queryParameters['title'] ?? 'Oreal - Soin Capillaire';
          final price = state.uri.queryParameters['price'] ?? '5 000 FCFA';
          final image = state.uri.queryParameters['image'] ?? 'assets/images/details_d_un_produit_img_0.png';
          final brand = state.uri.queryParameters['brand'] ?? 'L\'Oréal Professionnel';
          final desc = state.uri.queryParameters['desc'];
          final stockStr = state.uri.queryParameters['stock'];
          final stock = stockStr != null ? int.tryParse(stockStr) : null;

          return ProduitDetailScreen(
            produitId: id,
            slugSalon: slug,
            salonNom: salon,
            title: title,
            price: price,
            image: image,
            brand: brand,
            description: desc,
            stock: stock,
          );
        },
      ),

      // Route alias directe : Détail / Variantes du service d'un salon
      GoRoute(
        path: '/salons/:slug/services/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          final serviceId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ServiceVariantesScreen(
            slugSalon: slug,
            serviceId: serviceId,
          );
        },
      ),

      // Route alias directe : Détail du produit d'un salon
      GoRoute(
        path: '/salons/:slug/produits/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ProduitDetailScreen(
            produitId: id,
            slugSalon: slug,
          );
        },
      ),

      // Lire réalisation (Défilement vertical des vidéos du salon à partir de celle cliquée)
      GoRoute(
        path: RouteNames.lireRealisation,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final indexStr = state.uri.queryParameters['index'];
          final initialIndex = indexStr != null ? int.tryParse(indexStr) ?? 0 : 0;
          final salon = state.uri.queryParameters['salon'] ?? 'Beauty By Dika';
          final initials = state.uri.queryParameters['initials'] ?? 'BD';
          final slug = state.uri.queryParameters['slug'] ?? 'beauty-by-dika';
          return LireRealisationScreen(
            initialIndex: initialIndex,
            salonName: salon,
            initials: initials,
            salonSlug: slug,
          );
        },
      ),

      // Modifier mon profil
      GoRoute(
        path: RouteNames.modifierProfil,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ModifierProfilScreen(),
      ),

      // Changer de mot de passe
      GoRoute(
        path: RouteNames.changerMotDePasse,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChangerMotDePasseScreen(),
      ),

      // Mes favoris (Salons, Coiffures, Produits)
      GoRoute(
        path: RouteNames.mesFavoris,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final tabParam = state.uri.queryParameters['tab'];
          FavoriTab initialTab = FavoriTab.salons;
          if (tabParam == 'coiffures') {
            initialTab = FavoriTab.coiffures;
          } else if (tabParam == 'produits') {
            initialTab = FavoriTab.produits;
          }
          return MesFavorisScreen(initialTab: initialTab);
        },
      ),

      // Mes commandes (Tous les statuts)
      GoRoute(
        path: RouteNames.mesCommandes,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MesCommandesScreen(),
      ),

      // Détails d'une commande (Dispatcher vers l'écran spécifique au statut)
      GoRoute(
        path: RouteNames.commandeDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '1';
          final id = int.tryParse(idStr) ?? 1;
          return CommandeDetailDispatcherScreen(commandeId: id);
        },
      ),

      // Mes réclamations (Liste avec sélection de salon en haut)
      GoRoute(
        path: RouteNames.mesReclamations,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MesReclamationsScreen(),
      ),

      // Détails d'une réclamation (Dispatcher par statut)
      GoRoute(
        path: RouteNames.reclamationDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '1';
          final id = int.tryParse(idStr) ?? 1;
          final extraRec = state.extra is ReclamationModel ? state.extra as ReclamationModel : null;
          return ReclamationDetailScreen(id: id, initialReclamation: extraRec);
        },
      ),

      // Nouvelle réclamation
      GoRoute(
        path: RouteNames.nouvelleReclamation,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NouvelleReclamationScreen(),
      ),

      // Mes prestations (Historique des prestations avec filtre salon et multi-variantes)
      GoRoute(
        path: RouteNames.mesPrestations,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MesPrestationsScreen(),
      ),

      // Détails d'une prestation (Cover header style RDV et liste des variantes de services)
      GoRoute(
        path: RouteNames.prestationDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '1';
          final id = int.tryParse(idStr) ?? 1;
          final extraPres = state.extra is PrestationModel ? state.extra as PrestationModel : null;
          return PrestationDetailScreen(id: id, initialPrestation: extraPres);
        },
      ),

      // Paramètres de l'application
      GoRoute(
        path: RouteNames.parametres,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ParametresScreen(),
      ),

      // Mes recommandations (Routine capillaire 4 étapes)
      GoRoute(
        path: RouteNames.mesRecommandations,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MesRecommandationsScreen(),
      ),

      // Détails d'une recommandation spécifique
      GoRoute(
        path: RouteNames.recommandationDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '1';
          final id = int.tryParse(idStr) ?? 1;
          final extraReco = state.extra is RecommandationCapillaireModel
              ? state.extra as RecommandationCapillaireModel
              : null;
          return DetailsRecommandationScreen(id: id, initialRecommandation: extraReco);
        },
      ),

      // Détails d'un produit recommandé
      GoRoute(
        path: RouteNames.produitRecommandeDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final produit = state.extra is ProduitConseilModel
              ? state.extra as ProduitConseilModel
              : const ProduitConseilModel(
                  id: 1,
                  nom: 'Produit de Soin Capillaire',
                  marque: 'Kérastase',
                  description: 'Soin capillaire professionnel adapté à vos cheveux.',
                  modeUtilisation: 'Appliquer sur cheveux humides et masser doucement.',
                  etapeRoutine: 'SOIN_PROFOND',
                );
          return DetailsProduitRecommandeScreen(produit: produit);
        },
      ),

      // Historique des recommandations
      GoRoute(
        path: RouteNames.historiqueRecommandations,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HistoriqueRecommandationsScreen(),
      ),

      // Mon profil capillaire
      GoRoute(
        path: RouteNames.profilCapillaire,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfilCapillaireScreen(),
      ),
    ],
  );
});
