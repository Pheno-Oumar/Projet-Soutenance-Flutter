import 'models/notification_model.dart';

class NotificationMockData {
  static final List<NotificationModel> mockNotifications = [
    const NotificationModel(
      id: 1,
      titre: 'Rappel de rendez-vous demain',
      contenu:
          'Votre soin « Balayage Miel » avec Fanta Diallo est prévu demain à 14:30 au Salon ACI 2000.',
      type: 'RENDEZ_VOUS',
      referenceMetier: 'RDV-2025-0145',
      lu: false,
      dateCreation: 'Il y a 25 minutes • Rendez-vous',
    ),
    const NotificationModel(
      id: 2,
      titre: 'Acompte confirmé',
      contenu: 'Votre acompte a été validé avec succès par Orange Money.',
      type: 'PAIEMENT',
      referenceMetier: 'PAY-2025-0891',
      lu: true,
      dateCreation: 'Hier à 16:42 • Paiement',
    ),
    const NotificationModel(
      id: 3,
      titre: 'Réponse du Manager',
      contenu:
          'Le salon vous a répondu concernant le retard. Un avoir de 5 000 F a été crédité sur votre compte.',
      type: 'RECLAMATION',
      referenceMetier: 'REC-2025-0012',
      lu: true,
      dateCreation: '17 Septembre • Réclamation',
    ),
    const NotificationModel(
      id: 4,
      titre: 'Nouveau protocole capillaire disponible',
      contenu:
          'Découvrez le soin à la vapeur d\'armoise pour cuir chevelu sec, idéal pour votre texture 4A.',
      type: 'SERVICE',
      referenceMetier: 'SRV-2025-0004',
      lu: true,
      dateCreation: '12 Septembre • Soins',
    ),
  ];
}
