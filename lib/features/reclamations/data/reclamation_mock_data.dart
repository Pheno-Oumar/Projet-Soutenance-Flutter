import 'models/reclamation_model.dart';

class ReclamationMockData {
  static final List<ReclamationModel> mockReclamations = [
    // -------------------------------------------------------------
    // SALON BEAUTY
    // -------------------------------------------------------------
    const ReclamationModel(
      id: 1,
      codeReference: '#REC-2025-0123',
      salonNom: 'Salon Beauty',
      salonSlug: 'salon-beauty',
      salonAdresse: 'Dakar, Almadies',
      salonLogo: 'assets/images/rdv_tous_0.png',
      type: 'PRODUIT',
      objet: 'Problème sur la livraison du produit',
      description:
          "J'avais réservé un soin capillaire avec Fatou. La prise en charge a été décalée sans préavis. La coiffure était réussie mais l'attente trop longue.",
      statut: 'EN_ATTENTE',
      dateCreation: '12/04/2025',
    ),
    const ReclamationModel(
      id: 2,
      codeReference: '#REC-2025-0112',
      salonNom: 'Salon Beauty',
      salonSlug: 'salon-beauty',
      salonAdresse: 'Dakar, Almadies',
      salonLogo: 'assets/images/rdv_tous_0.png',
      type: 'PRODUIT',
      objet: 'Erreur d\'article dans la commande',
      description:
          "J'ai reçu un masque au karité au lieu du masque à l'huile d'argan commandé lors de ma dernière visite au salon.",
      statut: 'EN_COURS',
      dateCreation: '12/04/2025',
    ),
    const ReclamationModel(
      id: 3,
      codeReference: '#REC-2025-0098',
      salonNom: 'Salon Beauty',
      salonSlug: 'salon-beauty',
      salonAdresse: 'Dakar, Almadies',
      salonLogo: 'assets/images/rdv_tous_0.png',
      type: 'SERVICE',
      objet: 'Retard sur prestation planifiée',
      description:
          "J'avais réservé un soin capillaire avec Fatou. La prise en charge a été décalée sans préavis. La coiffure était réussie mais l'attente trop longue.",
      statut: 'RESOLUE',
      reponseTraitement:
          "Chère Aïcha, nous vous présentons nos excuses pour ce retard imprévu. Pour nous excuser, un soin hydratant vous est offert lors de votre prochaine visite au salon.",
      reponseAuteur: 'Direction Salon Beauty',
      reponseAuteurInitiales: 'SB',
      dateCreation: '28/08/2026',
      dateTraitement: '29/08/2026 à 11:20',
    ),
    const ReclamationModel(
      id: 4,
      codeReference: '#REC-2025-0064',
      salonNom: 'Salon Beauty',
      salonSlug: 'salon-beauty',
      salonAdresse: 'Dakar, Almadies',
      salonLogo: 'assets/images/rdv_tous_0.png',
      type: 'PRODUIT',
      objet: 'Demande de remboursement non conforme',
      description:
          "Le produit capillaire n'a pas produit les effets escomptés sur mes cheveux après plusieurs utilisations.",
      statut: 'REJETEE',
      reponseTraitement:
          "Bonjour, conformément à notre charte d'utilisation et aux conditions générales, les produits ouverts et utilisés ne peuvent faire l'objet d'un remboursement intégral. Nous restons disponibles pour un conseil personnalisé.",
      reponseAuteur: 'Direction Salon Beauty',
      reponseAuteurInitiales: 'SB',
      dateCreation: '12/04/2025',
      dateTraitement: '13/04/2025 à 15:40',
    ),

    // -------------------------------------------------------------
    // BEAUTY BY DIKA
    // -------------------------------------------------------------
    const ReclamationModel(
      id: 5,
      codeReference: '#REC-2025-0145',
      salonNom: 'Beauty By Dika',
      salonSlug: 'beauty-by-dika',
      salonAdresse: 'Bamako, Kalaban',
      salonLogo: 'assets/images/detail_img_1.jpg',
      type: 'SERVICE',
      objet: 'Tresses trop serrées au niveau des tempes',
      description:
          "La coiffeuse a trop tiré sur mes bordures lors de la réalisation des tresses, ce qui a causé une forte sensibilité.",
      statut: 'EN_ATTENTE',
      dateCreation: '14/04/2025',
    ),
    const ReclamationModel(
      id: 6,
      codeReference: '#REC-2025-0076',
      salonNom: 'Beauty By Dika',
      salonSlug: 'beauty-by-dika',
      salonAdresse: 'Bamako, Kalaban',
      salonLogo: 'assets/images/detail_img_1.jpg',
      type: 'PAIEMENT',
      objet: 'Double facturation par carte',
      description:
          "Le terminal de paiement a affiché une erreur au premier passage mais mon compte bancaire a été débité deux fois.",
      statut: 'RESOLUE',
      reponseTraitement:
          "Après vérification auprès de notre terminal, le doublon a été constaté et remboursé directement sur votre compte bancaire. Toutes nos excuses.",
      reponseAuteur: 'Comptabilité Beauty By Dika',
      reponseAuteurInitiales: 'BD',
      dateCreation: '18/03/2025',
      dateTraitement: '19/03/2025 à 14:10',
    ),

    // -------------------------------------------------------------
    // MATHY HAIR
    // -------------------------------------------------------------
    const ReclamationModel(
      id: 7,
      codeReference: '#REC-2025-0130',
      salonNom: 'Mathy Hair',
      salonSlug: 'mathy-hair',
      salonAdresse: 'Dakar, Mermoz',
      salonLogo: 'assets/images/salons_img_1.jpg',
      type: 'SERVICE',
      objet: 'Teinte de coloration différente de la photo',
      description:
          "La nuance marron glacé demandée s'est avérée plus foncée que sur le nuancier présenté avant la prestation.",
      statut: 'EN_COURS',
      dateCreation: '09/04/2025',
    ),
    const ReclamationModel(
      id: 8,
      codeReference: '#REC-2025-0042',
      salonNom: 'Mathy Hair',
      salonSlug: 'mathy-hair',
      salonAdresse: 'Dakar, Mermoz',
      salonLogo: 'assets/images/salons_img_1.jpg',
      type: 'SALON',
      objet: 'Annulation demandée hors délai',
      description:
          "J'ai demandé un remboursement de mon acompte suite à une annulation effectuée 1 heure avant le rendez-vous.",
      statut: 'REJETEE',
      reponseTraitement:
          "Les annulations doivent être effectuées au moins 24 heures à l'avance pour donner droit à un report d'acompte. Votre créneau n'ayant pu être réattribué, l'acompte est conservé.",
      reponseAuteur: 'Direction Mathy Hair',
      reponseAuteurInitiales: 'MH',
      dateCreation: '15/02/2025',
      dateTraitement: '16/02/2025 à 09:30',
    ),
  ];
}
