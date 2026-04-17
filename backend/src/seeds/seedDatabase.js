require('dotenv').config();
const sequelize = require('../models/index');
const User = require('../models/User');
const Service = require('../models/Service');
const Review = require('../models/Review');

async function seed() {
    try {
        await sequelize.sync({ force: true });
        console.log('✓ Tables créées');

        // ── Utilisateurs ──────────────────────────────────────────────
        const user = await User.create({
            firstName: 'Hervanio',
            lastName: 'Gbeke',
            email: 'test@allosecours.com',
            password: 'Password123!',
            phone: '+229 97 00 00 01',
            role: 'user',
        });
        console.log(`✓ Utilisateur créé : ${user.email} / Password123!`);

        const admin = await User.create({
            firstName: 'Admin',
            lastName: 'Secours',
            email: 'admin@allosecours.com',
            password: 'Admin123!',
            phone: '+229 97 00 00 02',
            role: 'admin',
        });
        console.log(`✓ Admin créé : ${admin.email} / Admin123!`);

        // ── Services de santé – Bénin ─────────────────────────────────
        const services = await Service.bulkCreate([
            // Hôpitaux
            {
                name: 'CNHU-HKM Cotonou',
                category: 'hospital',
                description: 'Centre National Hospitalier Universitaire Hubert Koutoukou Maga — principal hôpital de référence du Bénin.',
                address: 'Avenue Jean-Paul II',
                city: 'Cotonou',
                zipCode: '',
                country: 'Bénin',
                latitude: 6.3654,
                longitude: 2.4183,
                phone: '+229 21 30 01 55',
                email: 'contact@cnhu.bj',
                workingHours: '24h/24 - 7j/7',
                isOpen: true,
                rating: 4.2,
                reviewCount: 312,
                specialties: JSON.stringify(['Cardiologie', 'Neurologie', 'Pédiatrie', 'Maternité']),
                services: JSON.stringify(['Urgences', 'Consultations', 'Chirurgie', 'Imagerie', 'Laboratoire']),
                emergencyServices: true,
                verified: true,
            },
            {
                name: 'Clinique Louis Pasteur',
                category: 'hospital',
                description: 'Clinique privée moderne avec plateau technique complet.',
                address: 'Rue des Cheminots',
                city: 'Cotonou',
                zipCode: '',
                country: 'Bénin',
                latitude: 6.3721,
                longitude: 2.4235,
                phone: '+229 21 31 20 87',
                email: 'info@clinique-pasteur.bj',
                workingHours: '24h/24',
                isOpen: true,
                rating: 4.5,
                reviewCount: 178,
                specialties: JSON.stringify(['Gynécologie', 'Pédiatrie', 'Chirurgie']),
                services: JSON.stringify(['Consultations', 'Maternité', 'Chirurgie', 'Urgences']),
                emergencyServices: true,
                verified: true,
            },
            {
                name: 'Hôpital Saint Luc',
                category: 'hospital',
                description: 'Hôpital confessionnel de référence à Cotonou.',
                address: 'Akpakpa',
                city: 'Cotonou',
                zipCode: '',
                country: 'Bénin',
                latitude: 6.3589,
                longitude: 2.4320,
                phone: '+229 21 33 10 40',
                workingHours: '24h/24',
                isOpen: true,
                rating: 4.1,
                reviewCount: 89,
                specialties: JSON.stringify(['Médecine générale', 'Urgences']),
                services: JSON.stringify(['Urgences', 'Consultations', 'Laboratoire']),
                emergencyServices: true,
                verified: true,
            },
            {
                name: 'CHD Borgou – Parakou',
                category: 'hospital',
                description: 'Centre Hospitalier Départemental du Borgou, principal hôpital du nord du Bénin.',
                address: 'Route de Gaya',
                city: 'Parakou',
                zipCode: '',
                country: 'Bénin',
                latitude: 9.3372,
                longitude: 2.6289,
                phone: '+229 23 61 05 60',
                workingHours: '24h/24',
                isOpen: true,
                rating: 3.9,
                reviewCount: 203,
                specialties: JSON.stringify(['Médecine générale', 'Urgences', 'Maternité']),
                services: JSON.stringify(['Urgences', 'Maternité', 'Consultations']),
                emergencyServices: true,
                verified: true,
            },
            // Pharmacies
            {
                name: 'Pharmacie de la Caisse',
                category: 'pharmacy',
                description: 'Pharmacie bien approvisionnée en centre-ville de Cotonou.',
                address: 'Boulevard de la Marina',
                city: 'Cotonou',
                zipCode: '',
                country: 'Bénin',
                latitude: 6.3667,
                longitude: 2.4100,
                phone: '+229 21 31 25 80',
                workingHours: '8h-22h',
                isOpen: true,
                rating: 4.7,
                reviewCount: 145,
                specialties: JSON.stringify(['Médicaments', 'Parapharmacie', 'Vaccins']),
                services: JSON.stringify(['Vente de médicaments', 'Conseil pharmaceutique', 'Vaccination']),
                verified: true,
            },
            {
                name: 'Pharmacie Sainte Rita',
                category: 'pharmacy',
                description: 'Pharmacie de quartier avec service de livraison à domicile.',
                address: 'Haie Vive',
                city: 'Cotonou',
                zipCode: '',
                country: 'Bénin',
                latitude: 6.3748,
                longitude: 2.4270,
                phone: '+229 21 30 50 22',
                workingHours: '8h-21h',
                isOpen: true,
                rating: 4.4,
                reviewCount: 67,
                specialties: JSON.stringify(['Médicaments', 'Homéopathie']),
                services: JSON.stringify(['Vente de médicaments', 'Livraison à domicile']),
                verified: true,
            },
            // Spécialiste
            {
                name: 'Cabinet Dr. Ahouansou',
                category: 'specialist',
                description: 'Cabinet de cardiologie avec équipements modernes à Cotonou.',
                address: 'Quartier Gbèdjromèdé',
                city: 'Cotonou',
                zipCode: '',
                country: 'Bénin',
                latitude: 6.3802,
                longitude: 2.4150,
                phone: '+229 97 12 34 56',
                email: 'dr.ahouansou@gmail.com',
                workingHours: 'Lun-Ven 9h-17h',
                isOpen: true,
                rating: 4.8,
                reviewCount: 54,
                specialties: JSON.stringify(['Cardiologie', 'Hypertension', 'Diabète']),
                services: JSON.stringify(['Consultations', 'ECG', 'Échographie cardiaque']),
                verified: true,
            },
            // Urgences
            {
                name: 'SAMU Bénin – Cotonou',
                category: 'emergency',
                description: 'Service d\'Aide Médicale Urgente du Bénin. Appelez le 13.',
                address: 'CNHU, Avenue Jean-Paul II',
                city: 'Cotonou',
                zipCode: '',
                country: 'Bénin',
                latitude: 6.3654,
                longitude: 2.4183,
                phone: '13',
                workingHours: '24h/24 - 7j/7',
                isOpen: true,
                rating: 4.9,
                reviewCount: 620,
                specialties: JSON.stringify(['Urgences vitales', 'Transport médicalisé']),
                services: JSON.stringify(['SMUR', 'Régulation médicale', 'Transport d\'urgence']),
                emergencyServices: true,
                verified: true,
            },
        ]);

        console.log(`✓ ${services.length} services créés`);

        // ── Avis ──────────────────────────────────────────────────────
        await Review.bulkCreate([
            {
                serviceId: services[0].id,
                userId: user.id,
                userName: 'Hervanio G.',
                rating: 5,
                comment: 'Excellent hôpital, personnel très compétent et réactif.',
            },
            {
                serviceId: services[0].id,
                userId: null,
                userName: 'Kouassi A.',
                rating: 4,
                comment: 'Très bon service, prise en charge rapide aux urgences.',
            },
            {
                serviceId: services[4].id,
                userId: user.id,
                userName: 'Hervanio G.',
                rating: 5,
                comment: 'Pharmacien très disponible, médicaments bien stockés.',
            },
        ]);

        console.log('✓ Avis créés');

        console.log(`
╔══════════════════════════════════════════════╗
║         SEED BÉNIN TERMINÉ AVEC SUCCÈS       ║
╠══════════════════════════════════════════════╣
║  Utilisateur : test@allosecours.com          ║
║  Mot de passe : Password123!                 ║
╠══════════════════════════════════════════════╣
║  Admin : admin@allosecours.com               ║
║  Mot de passe : Admin123!                    ║
╠══════════════════════════════════════════════╣
║  Services : 8 établissements du Bénin        ║
║  SAMU Bénin : 13  |  Pompiers : 18           ║
║  Police : 117     |  Cotonou GPS: 6.37/2.42  ║
╚══════════════════════════════════════════════╝
        `);
    } catch (error) {
        console.error('Erreur seed:', error.message);
    } finally {
        await sequelize.close();
    }
}

seed();
