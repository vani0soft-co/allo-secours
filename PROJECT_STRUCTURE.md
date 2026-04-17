🎉 # PROJET ALLO SECOURS - STRUCTURE COMPLÈTE

## 📁 Arborescence du Projet

```
allo-secours/
│
├── 📄 pubspec.yaml                    # Gestionnaire de dépendances
├── 📄 pubspec.lock                    # Versions verrouillées
├── 📄 analysis_options.yaml           # Configuration du linter
├── 📄 .gitignore                      # Fichiers à ignorer
├── 📄 .env.example                    # Exemple variables d'environnement
│
├── 📄 README.md                       # Documentation principale
├── 📄 PROJECT_DOCUMENTATION.md        # Documentation détaillée
├── 📄 DEVELOPMENT_NOTES.md            # Notes de développement
├── 📄 CONTRIBUTING.md                 # Guide de contribution
├── 📄 COMMANDS.md                     # Commandes utiles
│
├── 📂 lib/                            # Code source Flutter
│   ├── 📄 main.dart                   # Point d'entrée
│   │
│   ├── 📂 config/                     # Configuration
│   │   ├── 📄 app_colors.dart         # Palette de couleurs
│   │   └── 📄 app_routes.dart         # Routes de navigation
│   │
│   ├── 📂 constants/                  # Constantes globales
│   │   └── 📄 app_constants.dart      # Constantes de l'app
│   │
│   ├── 📂 models/                     # Modèles de données
│   │   ├── 📄 service_model.dart      # Modèle Service
│   │   ├── 📄 location_model.dart     # Modèle Location
│   │   └── 📄 review_model.dart       # Modèle Review
│   │
│   ├── 📂 providers/                  # Gestion d'état (Provider)
│   │   ├── 📄 location_provider.dart  # Gère la localisation
│   │   └── 📄 services_provider.dart  # Gère les services
│   │
│   ├── 📂 services/                   # Services et logique métier
│   │   ├── 📄 api_service.dart        # Requêtes API
│   │   ├── 📄 storage_service.dart    # Stockage local
│   │   └── 📄 notification_service.dart # Notifications
│   │
│   ├── 📂 screens/                    # Pages de l'application
│   │   ├── 📄 home_screen.dart        # Accueil
│   │   ├── 📄 services_screen.dart    # Liste des services
│   │   ├── 📄 hospitals_screen.dart   # Hôpitaux
│   │   ├── 📄 pharmacies_screen.dart  # Pharmacies
│   │   ├── 📄 emergency_screen.dart   # Urgences
│   │   ├── 📄 service_detail_screen.dart # Détails service
│   │   ├── 📄 map_screen.dart         # Carte (Google Maps)
│   │   ├── 📄 my_searches_screen.dart # Historique recherche
│   │   ├── 📄 my_opinion_screen.dart  # Avis utilisateur
│   │   └── 📄 profile_screen.dart     # Profil utilisateur
│   │
│   ├── 📂 widgets/                    # Widgets réutilisables
│   │   ├── 📄 custom_app_bar.dart     # Barre d'app personnalisée
│   │   ├── 📄 service_category_card.dart # Carte catégorie
│   │   └── 📄 service_list_tile.dart  # Tuile liste service
│   │
│   └── 📂 utils/                      # Utilitaires
│       ├── 📄 extensions.dart         # Extensions Dart
│       ├── 📄 exceptions.dart         # Exceptions personnalisées
│       └── 📄 mock_data.dart          # Données de test
│
├── 📂 android/                        # Configuration Android
│   ├── 📄 build.gradle                # Configuration Gradle
│   └── 📄 AndroidManifest.xml         # Permissions et config
│
├── 📂 ios/                            # Configuration iOS
│   ├── 📄 Info.plist                  # Configuration iOS
│   └── 📄 Podfile                     # Dépendances Cocoapods
│
├── 📂 web/                            # Support web
│   └── 📄 index.html
│
├── 📂 assets/                         # Ressources (images, icônes)
│   ├── 📂 images/
│   ├── 📂 icons/
│   ├── 📂 fonts/
│   └── 📂 lottie/
│
├── 📂 test/                           # Tests unitaires
│   ├── 📄 *_test.dart
│   └── 📂 widget/                     # Tests de widgets
│
└── 📂 integration_test/               # Tests d'intégration
    └── 📄 app_test.dart
```

## 📊 Statistiques du Projet

| Catégorie | Nombre |
|-----------|--------|
| Fichiers Dart | 30+ |
| Écrans | 10 |
| Providers | 2 |
| Services | 3 |
| Widgets | 3+ |
| Modèles | 3 |
| Lignes de Code | ~3000+ |

## 🎯 Fonctionnalités Implémentées

✅ Structure de base Flutter
✅ Système de navigation avec GetX
✅ Gestion d'état avec Provider
✅ 10 écrans complets
✅ Modèles de données
✅ Service API avec Dio
✅ LocationProvider pour géolocalisation
✅ ServicesProvider pour filtrage/recherche
✅ Widgets réutilisables
✅ Configuration des couleurs
✅ Stockage local (SharedPreferences)
✅ Gestion des erreurs personnalisées
✅ Extensions Dart utiles
✅ Données de test (Mock)

## 🚀 Fonctionnalités à Implémenter

⏳ Google Maps intégration complète
⏳ Authentification utilisateur
⏳ Backend API réel
⏳ Notifications push
⏳ Partage de localisation
⏳ Tests complets
⏳ Animations (Lottie)
⏳ Mode dark
⏳ Internationalization (i18n)
⏳ Synchronisation cloud

## 📦 Dépendances Principales

```yaml
flutter_sdk: >=3.0.0
provider: ^6.0.0           # State management
get: ^4.6.5                # Navigation & routes
geolocator: ^9.0.2         # Géolocalisation
google_maps_flutter: ^2.5.0 # Google Maps
dio: ^5.3.0                # Requêtes HTTP
shared_preferences: ^2.2.0 # Stockage local
permission_handler: ^11.4.4 # Gestion permissions
```

## 🔐 Permissions Configurées

### Android
```xml
ACCESS_FINE_LOCATION
ACCESS_COARSE_LOCATION
INTERNET
ACCESS_NETWORK_STATE
```

### iOS
```xml
NSLocationWhenInUseUsageDescription
NSLocationAlwaysAndWhenInUseUsageDescription
NSCameraUsageDescription
NSPhotoLibraryUsageDescription
```

## 🎨 Palette de Couleurs

**Primary**: `#003D7A` (Bleu foncé)
**Secondary**: `#00A651` (Vert)
**Accent**: `#FFC107` (Or)
**Error**: `#D32F2F` (Rouge)
**Success**: `#4CAF50` (Vert clair)
**Background**: `#F5F5F5` (Gris clair)

## 🌐 API Endpoints

```
GET    /services              # Tous les services
GET    /services/:id          # Détails d'un service
GET    /services/nearby       # Services à proximité
POST   /services/:id/reviews  # Ajouter un avis
GET    /services/:id/reviews  # Récupérer les avis
```

## 💻 Commandes Essentielles

```bash
# Démarrer
flutter run

# Nettoyer
flutter clean && flutter pub get

# Formater
dart format lib/

# Analyser
flutter analyze

# Tester
flutter test

# Builder
flutter build apk --release
flutter build ios --release
```

## 📚 Structure des Fichiers

### Conventions de Nommage
- **Fichiers**: `snake_case.dart` (`app_colors.dart`)
- **Classes**: `PascalCase` (`HomeScreen`)
- **Variables/Fonctions**: `camelCase` (`currentLocation`)
- **Constantes**: `UPPER_CASE` ou `camelCase` selon contexte

## 🔧 Configuration Requise

- Flutter >= 3.0.0
- Dart >= 3.0.0
- Android minSdkVersion >= 21
- iOS >= 11.0
- Google Maps API Key
- Serveur backend

## 📖 Documentation

- **[README.md](README.md)** - Vue d'ensemble et installation
- **[PROJECT_DOCUMENTATION.md](PROJECT_DOCUMENTATION.md)** - Documentation complète
- **[DEVELOPMENT_NOTES.md](DEVELOPMENT_NOTES.md)** - Notes de développement
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Guide de contribution
- **[COMMANDS.md](COMMANDS.md)** - Commandes utiles

## 🎓 Points Clés

1. **Architecture**: Clean Architecture avec Provider/GetX
2. **State Management**: Provider pour les données, GetX pour la navigation
3. **API**: Service centralisé avec Dio pour les requêtes
4. **Storage**: SharedPreferences pour les données persistantes
5. **Géolocalisation**: Geolocator pour la localisation en temps réel
6. **Navigation**: Routes nommées avec GetX
7. **Erreurs**: Exceptions personnalisées pour meilleure gestion
8. **Code**: Formaté et analysé selon les normes Flutter

## 🚀 Prochaines Étapes

1. Implémenter l'authentification
2. Créer le backend API
3. Intégrer Google Maps complètement
4. Ajouter les notifications push
5. Écrire les tests complets
6. Optimiser les performances
7. Préparer la publication

## 📞 Support

Pour plus d'informations, consultez:
- La documentation complète
- Les notes de développement
- Les commandes utiles
- Le guide de contribution

---

✨ **Projet Allo Secours - Application de Géolocalisation de Services de Santé** ✨
