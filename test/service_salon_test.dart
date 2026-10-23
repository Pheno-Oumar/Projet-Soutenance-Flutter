import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hair_style/features/salon/data/models/service_salon_model.dart';

void main() {
  group('ServiceSalonModel & VarianteServiceModel Tests', () {
    test('VarianteServiceModel fromJson and getters work properly', () {
      final json = {
        'id': 101,
        'nom': 'Tresses Égyptiennes',
        'description': 'Tresses fines et soignées avec finitions dorées',
        'dureeMinutes': 45,
        'prix': 7500.0,
        'imageUrl': 'https://res.cloudinary.com/test/variante1.jpg',
        'imagesUrls': [
          'https://res.cloudinary.com/test/variante1.jpg',
          'https://res.cloudinary.com/test/variante2.jpg'
        ],
        'statut': true,
      };

      final variante = VarianteServiceModel.fromJson(json);

      expect(variante.id, 101);
      expect(variante.nom, 'Tresses Égyptiennes');
      expect(variante.description, 'Tresses fines et soignées avec finitions dorées');
      expect(variante.dureeMinutes, 45);
      expect(variante.prix, 7500.0);
      expect(variante.mainImage, 'https://res.cloudinary.com/test/variante1.jpg');
      expect(variante.imagesUrls.length, 2);
      expect(variante.statut, true);
    });

    test('ServiceSalonModel calculates minPrix correctly', () {
      final json = {
        'id': 10,
        'nom': 'Coiffures Protectrices',
        'description': 'Collection de tresses et tissages',
        'imageUrl': 'https://res.cloudinary.com/test/service10.jpg',
        'statut': true,
        'variantes': [
          {
            'id': 101,
            'nom': 'Variante A',
            'prix': 10000.0,
            'dureeMinutes': 60,
            'statut': true,
          },
          {
            'id': 102,
            'nom': 'Variante B',
            'prix': 5000.0,
            'dureeMinutes': 30,
            'statut': true,
          },
          {
            'id': 103,
            'nom': 'Variante C (Inactive)',
            'prix': 2000.0,
            'dureeMinutes': 15,
            'statut': false,
          },
        ],
      };

      final service = ServiceSalonModel.fromJson(json);

      expect(service.id, 10);
      expect(service.nom, 'Coiffures Protectrices');
      expect(service.variantes.length, 3);
      // Min price should ignore inactive variante (2000) and pick active min (5000)
      expect(service.minPrix, 5000.0);
    });
  });
}
