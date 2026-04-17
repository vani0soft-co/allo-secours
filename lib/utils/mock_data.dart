import 'package:allo_secours/models/service_model.dart';

/// Données de démonstration centrées sur le Bénin (fallback sans backend)
class MockData {
  static final List<Service> mockServices = [
    // ── Hôpitaux ──────────────────────────────────────────────────────────
    Service(
      id: '1',
      name: 'CNHU-HKM Cotonou',
      category: 'hospital',
      address: 'Avenue Jean-Paul II, Cotonou',
      latitude: 6.3654,
      longitude: 2.4183,
      phone: '+229 21 30 01 55',
      email: 'contact@cnhu.bj',
      rating: 4.2,
      reviewCount: 312,
      imageUrl: null,
      specialties: ['Cardiologie', 'Neurologie', 'Pédiatrie', 'Maternité'],
      isOpen: true,
      workingHours: '24h/24 - 7j/7',
      description:
          'Centre National Hospitalier Universitaire Hubert Koutoukou Maga — principal hôpital de référence du Bénin.',
      services: ['Urgences', 'Consultations', 'Chirurgie', 'Imagerie', 'Laboratoire'],
      distance: 1.2,
    ),
    Service(
      id: '2',
      name: 'Clinique Louis Pasteur',
      category: 'hospital',
      address: 'Rue des Cheminots, Cotonou',
      latitude: 6.3721,
      longitude: 2.4235,
      phone: '+229 21 31 20 87',
      email: 'info@clinique-pasteur.bj',
      rating: 4.5,
      reviewCount: 178,
      imageUrl: null,
      specialties: ['Gynécologie', 'Pédiatrie', 'Chirurgie'],
      isOpen: true,
      workingHours: '24h/24',
      description: 'Clinique privée moderne avec plateau technique complet.',
      services: ['Consultations', 'Maternité', 'Chirurgie', 'Urgences'],
      distance: 2.1,
    ),
    Service(
      id: '3',
      name: 'Hôpital Saint Luc',
      category: 'hospital',
      address: 'Akpakpa, Cotonou',
      latitude: 6.3589,
      longitude: 2.4320,
      phone: '+229 21 33 10 40',
      email: null,
      rating: 4.1,
      reviewCount: 89,
      imageUrl: null,
      specialties: ['Médecine générale', 'Urgences'],
      isOpen: true,
      workingHours: '24h/24',
      description: 'Hôpital confessionnel de référence à Cotonou.',
      services: ['Urgences', 'Consultations', 'Laboratoire'],
      distance: 3.4,
    ),

    // ── Pharmacies ────────────────────────────────────────────────────────
    Service(
      id: '4',
      name: 'Pharmacie de la Caisse',
      category: 'pharmacy',
      address: 'Boulevard de la Marina, Cotonou',
      latitude: 6.3667,
      longitude: 2.4100,
      phone: '+229 21 31 25 80',
      email: null,
      rating: 4.7,
      reviewCount: 145,
      imageUrl: null,
      specialties: ['Médicaments', 'Parapharmacie', 'Vaccins'],
      isOpen: true,
      workingHours: '8h-22h',
      description: 'Pharmacie bien approvisionnée en centre-ville.',
      services: ['Vente de médicaments', 'Conseil pharmaceutique', 'Vaccination'],
      distance: 0.8,
    ),
    Service(
      id: '5',
      name: 'Pharmacie Sainte Rita',
      category: 'pharmacy',
      address: 'Haie Vive, Cotonou',
      latitude: 6.3748,
      longitude: 2.4270,
      phone: '+229 21 30 50 22',
      email: null,
      rating: 4.4,
      reviewCount: 67,
      imageUrl: null,
      specialties: ['Médicaments', 'Homéopathie'],
      isOpen: true,
      workingHours: '8h-21h',
      description: 'Pharmacie de quartier avec service de livraison.',
      services: ['Vente de médicaments', 'Livraison à domicile'],
      distance: 1.5,
    ),

    // ── Spécialistes ──────────────────────────────────────────────────────
    Service(
      id: '6',
      name: 'Cabinet Dr. Ahouansou',
      category: 'specialist',
      address: 'Quartier Gbèdjromèdé, Cotonou',
      latitude: 6.3802,
      longitude: 2.4150,
      phone: '+229 97 12 34 56',
      email: 'dr.ahouansou@gmail.com',
      rating: 4.8,
      reviewCount: 54,
      imageUrl: null,
      specialties: ['Cardiologie', 'Hypertension', 'Diabète'],
      isOpen: true,
      workingHours: 'Lun-Ven 9h-17h',
      description: 'Cabinet de cardiologie avec équipements modernes.',
      services: ['Consultations', 'ECG', 'Échographie cardiaque'],
      distance: 2.8,
    ),
    Service(
      id: '7',
      name: 'CHD Borgou – Parakou',
      category: 'hospital',
      address: 'Route de Gaya, Parakou',
      latitude: 9.3372,
      longitude: 2.6289,
      phone: '+229 23 61 05 60',
      email: null,
      rating: 3.9,
      reviewCount: 203,
      imageUrl: null,
      specialties: ['Médecine générale', 'Urgences', 'Maternité'],
      isOpen: true,
      workingHours: '24h/24',
      description: 'Centre Hospitalier Départemental du Borgou.',
      services: ['Urgences', 'Maternité', 'Consultations'],
      distance: 350.0,
    ),

    // ── Urgences ──────────────────────────────────────────────────────────
    Service(
      id: '8',
      name: 'SAMU Bénin – Cotonou',
      category: 'emergency',
      address: 'CNHU, Avenue Jean-Paul II, Cotonou',
      latitude: 6.3654,
      longitude: 2.4183,
      phone: '13',
      email: null,
      rating: 4.9,
      reviewCount: 620,
      imageUrl: null,
      specialties: ['Urgences vitales', 'Transport médicalisé'],
      isOpen: true,
      workingHours: '24h/24 - 7j/7',
      description: 'Service d\'Aide Médicale Urgente du Bénin. Appelez le 13.',
      services: ['SMUR', 'Régulation médicale', 'Transport d\'urgence'],
      distance: 1.2,
    ),
  ];

  static List<Service> getServicesByCategory(String category) {
    return mockServices.where((s) => s.category == category).toList();
  }

  static Service? getServiceById(String id) {
    try {
      return mockServices.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}
