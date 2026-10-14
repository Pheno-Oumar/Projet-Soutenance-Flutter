import '../../rendezvous/data/rendezvous_mock_data.dart';
import 'models/prestation_model.dart';

class PrestationMockData {
  static const List<SalonItem> salonsDisponibles = [
    SalonItem(
      nom: 'Salon Beauty',
      slug: 'salon-beauty',
      adresse: 'Dakar, Almadies',
      logo: 'assets/images/rdv_tous_0.png',
    ),
    SalonItem(
      nom: 'Hair & Co',
      slug: 'hair-co',
      adresse: 'Dakar, Mermoz',
      logo: 'assets/images/rdv_tous_1.png',
    ),
    SalonItem(
      nom: 'Beauty By Dika',
      slug: 'beauty-by-dika',
      adresse: 'Dakar, Plateau',
      logo: 'assets/images/rdv_tous_2.png',
    ),
    SalonItem(
      nom: 'Salon Chic',
      slug: 'salon-chic',
      adresse: 'Dakar, Ngor',
      logo: 'assets/images/rdv_tous_3.png',
    ),
  ];

  static final List<PrestationModel> mockPrestations = [
    // -------------------------------------------------------------
    // 1. SALON BEAUTY - Soin capillaire (2 variantes) - Terminée
    // -------------------------------------------------------------
    const PrestationModel(
      id: 1,
      codeReference: '#PRES-2025-0145',
      salonSlug: 'salon-beauty',
      salonNom: 'Salon Beauty',
      salonAdresse: 'Dakar, Almadies',
      salonLogo: 'assets/images/rdv_tous_0.png',
      salonCover: 'assets/images/rdv_dt_venir_0.jpeg',
      coiffeurNom: 'S.',
      coiffeurPrenom: 'Fatou',
      nomClient: 'Diallo',
      prenomClient: 'Aïcha',
      dateHeureDebut: '15/04/2025 • 10:00',
      dateHeureFin: '15/04/2025 • 11:30',
      statut: 'TERMINEE',
      montantTotal: 25000.0,
      modePaiement: 'Paiement espèces au salon',
      lignes: [
        LignePrestationModel(
          id: 101,
          varianteServiceId: 1,
          nomService: 'Soin capillaire',
          nomVariante: 'Soin hydratant profond à l\'aloe vera',
          prix: 15000.0,
          dureeMinutes: 45,
          imageUrl: 'assets/images/prestation_soin.jpg',
        ),
        LignePrestationModel(
          id: 102,
          varianteServiceId: 2,
          nomService: 'Brushing',
          nomVariante: 'Brushing soyeux finition lisse',
          prix: 10000.0,
          dureeMinutes: 30,
          imageUrl: 'assets/images/prestation_brushing.jpg',
        ),
      ],
    ),

    // -------------------------------------------------------------
    // 2. SALON BEAUTY - Brushing (2 variantes) - Terminée
    // -------------------------------------------------------------
    const PrestationModel(
      id: 2,
      codeReference: '#PRES-2025-0112',
      salonSlug: 'salon-beauty',
      salonNom: 'Salon Beauty',
      salonAdresse: 'Dakar, Almadies',
      salonLogo: 'assets/images/rdv_tous_0.png',
      salonCover: 'assets/images/rdv_dt_passe_0.jpeg',
      coiffeurNom: 'S.',
      coiffeurPrenom: 'Fatou',
      nomClient: 'Diallo',
      prenomClient: 'Aïcha',
      dateHeureDebut: '02/04/2025 • 14:00',
      dateHeureFin: '02/04/2025 • 15:00',
      statut: 'TERMINEE',
      montantTotal: 17000.0,
      modePaiement: 'Orange Money',
      lignes: [
        LignePrestationModel(
          id: 201,
          varianteServiceId: 2,
          nomService: 'Brushing',
          nomVariante: 'Brushing volumateur bouclé',
          prix: 12000.0,
          dureeMinutes: 45,
          imageUrl: 'assets/images/prestation_brushing.jpg',
        ),
        LignePrestationModel(
          id: 202,
          varianteServiceId: 3,
          nomService: 'Soin des pointes',
          nomVariante: 'Sérum nutritif réparateur sans rinçage',
          prix: 5000.0,
          dureeMinutes: 15,
          imageUrl: 'assets/images/prestation_soin.jpg',
        ),
      ],
    ),

    // -------------------------------------------------------------
    // 3. HAIR & CO - Coloration (2 variantes) - Annulée
    // -------------------------------------------------------------
    const PrestationModel(
      id: 3,
      codeReference: '#PRES-2025-0089',
      salonSlug: 'hair-co',
      salonNom: 'Hair & Co',
      salonAdresse: 'Dakar, Mermoz',
      salonLogo: 'assets/images/rdv_tous_1.png',
      salonCover: 'assets/images/rdv_dt_passe1_0.jpeg',
      coiffeurNom: 'D.',
      coiffeurPrenom: 'Marie',
      nomClient: 'Diallo',
      prenomClient: 'Aïcha',
      dateHeureDebut: '18/03/2025 • 11:30',
      dateHeureFin: '18/03/2025 • 13:30',
      statut: 'ANNULEE',
      montantTotal: 45000.0,
      motifAnnulation: 'Annulation demandée par la cliente suite à un empêchement professionnel.',
      modePaiement: 'Non réglé',
      lignes: [
        LignePrestationModel(
          id: 301,
          varianteServiceId: 4,
          nomService: 'Coloration',
          nomVariante: 'Balayage miel doré lumineux',
          prix: 35000.0,
          dureeMinutes: 90,
          imageUrl: 'assets/images/prestation_coloration.jpg',
        ),
        LignePrestationModel(
          id: 302,
          varianteServiceId: 5,
          nomService: 'Shampoing éclat',
          nomVariante: 'Soin fixateur de couleur protecteur',
          prix: 10000.0,
          dureeMinutes: 20,
          imageUrl: 'assets/images/service_img_0.jpg',
        ),
      ],
    ),

    // -------------------------------------------------------------
    // 4. BEAUTY BY DIKA - Tresses africaines (2 variantes) - Terminée
    // -------------------------------------------------------------
    const PrestationModel(
      id: 4,
      codeReference: '#PRES-2025-0062',
      salonSlug: 'beauty-by-dika',
      salonNom: 'Beauty By Dika',
      salonAdresse: 'Dakar, Plateau',
      salonLogo: 'assets/images/rdv_tous_2.png',
      salonCover: 'assets/images/rdv_dt_venir_0.jpeg',
      coiffeurNom: 'Dika',
      coiffeurPrenom: 'Salimata',
      nomClient: 'Diallo',
      prenomClient: 'Aïcha',
      dateHeureDebut: '28/02/2025 • 09:30',
      dateHeureFin: '28/02/2025 • 12:00',
      statut: 'TERMINEE',
      montantTotal: 35000.0,
      modePaiement: 'Wave Sénégal',
      lignes: [
        LignePrestationModel(
          id: 401,
          varianteServiceId: 6,
          nomService: 'Tresses africaines',
          nomVariante: 'Box Braids mi-longues avec perles bois',
          prix: 25000.0,
          dureeMinutes: 120,
          imageUrl: 'assets/images/details_d_une_variante_img_0.png',
        ),
        LignePrestationModel(
          id: 402,
          varianteServiceId: 7,
          nomService: 'Bain d\'huiles',
          nomVariante: 'Massage crânien aux huiles précieuses',
          prix: 10000.0,
          dureeMinutes: 30,
          imageUrl: 'assets/images/prestation_soin.jpg',
        ),
      ],
    ),

    // -------------------------------------------------------------
    // 5. SALON CHIC - Lissage brésilien (2 variantes) - Terminée
    // -------------------------------------------------------------
    const PrestationModel(
      id: 5,
      codeReference: '#PRES-2025-0041',
      salonSlug: 'salon-chic',
      salonNom: 'Salon Chic',
      salonAdresse: 'Dakar, Ngor',
      salonLogo: 'assets/images/rdv_tous_3.png',
      salonCover: 'assets/images/rdv_dt_passe_0.jpeg',
      coiffeurNom: 'N.',
      coiffeurPrenom: 'Khadija',
      nomClient: 'Diallo',
      prenomClient: 'Aïcha',
      dateHeureDebut: '20/01/2025 • 15:00',
      dateHeureFin: '20/01/2025 • 17:30',
      statut: 'TERMINEE',
      montantTotal: 48000.0,
      modePaiement: 'Carte bancaire',
      lignes: [
        LignePrestationModel(
          id: 501,
          varianteServiceId: 8,
          nomService: 'Lissage brésilien',
          nomVariante: 'Traitement kératine thermo-actif',
          prix: 40000.0,
          dureeMinutes: 120,
          imageUrl: 'assets/images/service_img_0.jpg',
        ),
        LignePrestationModel(
          id: 502,
          varianteServiceId: 9,
          nomService: 'Soin protecteur',
          nomVariante: 'Masque scellant brillance intense',
          prix: 8000.0,
          dureeMinutes: 20,
          imageUrl: 'assets/images/prestation_soin.jpg',
        ),
      ],
    ),

    // -------------------------------------------------------------
    // 6. HAIR & CO - Manucure & Pédicure (2 variantes) - Annulée
    // -------------------------------------------------------------
    const PrestationModel(
      id: 6,
      codeReference: '#PRES-2025-0018',
      salonSlug: 'hair-co',
      salonNom: 'Hair & Co',
      salonAdresse: 'Dakar, Mermoz',
      salonLogo: 'assets/images/rdv_tous_1.png',
      salonCover: 'assets/images/rdv_dt_passe1_0.jpeg',
      coiffeurNom: 'D.',
      coiffeurPrenom: 'Marie',
      nomClient: 'Diallo',
      prenomClient: 'Aïcha',
      dateHeureDebut: '05/01/2025 • 16:00',
      dateHeureFin: '05/01/2025 • 17:30',
      statut: 'ANNULEE',
      montantTotal: 27000.0,
      motifAnnulation: 'Annulation en raison d\'un retard d\'avion de la cliente.',
      modePaiement: 'Non réglé',
      lignes: [
        LignePrestationModel(
          id: 601,
          varianteServiceId: 10,
          nomService: 'Manucure russe',
          nomVariante: 'Pose vernis semi-permanent french',
          prix: 12000.0,
          dureeMinutes: 45,
          imageUrl: 'assets/images/prestation_coloration.jpg',
        ),
        LignePrestationModel(
          id: 602,
          varianteServiceId: 11,
          nomService: 'Pédicure bien-être',
          nomVariante: 'Soin des pieds relaxant et gommage',
          prix: 15000.0,
          dureeMinutes: 45,
          imageUrl: 'assets/images/rdv_dt_passe_2.jpeg',
        ),
      ],
    ),
  ];
}
