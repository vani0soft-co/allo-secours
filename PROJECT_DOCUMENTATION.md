# Documentation du Projet Allo Secours

## 📱 Vue d'ensemble

Allo Secours est une application mobile développée avec **Flutter et Dart** qui permet aux utilisateurs de trouver facilement les hôpitaux, pharmacies, spécialistes et services d'urgence à proximité grâce à la géolocalisation.

## 🗂️ Structure du projet

```
allo_secours/
├── lib/
│   ├── config/              # Configuration de l'app
│   │   ├── app_colors.dart
│   │   └── app_routes.dart
│   ├── constants/           # Constantes globales
│   │   └── app_constants.dart
│   ├── models/              # Modèles de données
│   │   ├── service_model.dart
│   │   ├── location_model.dart
│   │   └── review_model.dart
│   ├── providers/           # Gestion d'état (Provider)
│   │   ├── location_provider.dart
│   │   └── services_provider.dart
│   ├── screens/             # Écrans/Pages
│   │   ├── home_screen.dart
│   │   ├── services_screen.dart
│   │   ├── hospitals_screen.dart
│   │   ├── pharmacies_screen.dart
│   │   ├── emergency_screen.dart
│   │   ├── service_detail_screen.dart
│   │   ├── map_screen.dart
│   │   ├── my_searches_screen.dart
│   │   ├── my_opinion_screen.dart
│   │   └── profile_screen.dart
│   ├── services/            # Services et logique
│   │   ├── api_service.dart
│   │   ├── storage_service.dart
│   │   └── notification_service.dart
│   ├── widgets/             # Widgets réutilisables
│   │   ├── custom_app_bar.dart
│   │   ├── service_category_card.dart
│   │   └── service_list_tile.dart
│   ├── utils/               # Utilitaires
│   │   ├── extensions.dart
│   │   ├── exceptions.dart
│   │   └── mock_data.dart
│   └── main.dart
├── android/                 # Configuration Android
├── ios/                     # Configuration iOS
├── pubspec.yaml            # Dépendances
├── analysis_options.yaml   # Linter configuration
└── README.md               # Documentation
```

## 🚀 Fonctionnalités Principales

### 1. **Accueil (Home Screen)**
- Affichage du nom de l'utilisateur
- Barre de recherche
- Carrousel d'images promotionnelles
- Grille de catégories (9 catégories)
- Navigation par bottom navigation bar

### 2. **Services**
- Liste complète des services
- Recherche en temps réel
- Filtrage par catégorie
- Tri par distance/évaluation
- Affichage du statut (Ouvert/Fermé)

### 3. **Hôpitaux**
- Localisation des hôpitaux proches
- Informations de base
- Évaluations

### 4. **Pharmacies**
- Localisation des pharmacies
- Horaires d'ouverture
- Services disponibles

### 5. **Urgences**
- Numéro d'urgence affiché
- Accès rapide à l'appel d'ambulance
- Urgences à proximité

### 6. **Détails du Service**
- Photos du service
- Évaluation et avis
- Adresse et téléphone
- Boutons d'appel et géolocalisation
- Avis des utilisateurs

### 7. **Carte (Maps)**
- Intégration Google Maps
- Localisation en temps réel
- Affichage des services proches

### 8. **Historique de Recherche**
- Sauvegarde des recherches
- Accès facile aux recherches précédentes

### 9. **Avis des Utilisateurs**
- Système d'évaluation 5 étoiles
- Formulaire de commentaires
- Envoi des avis

### 10. **Profil Utilisateur**
- Informations personnelles
- Accès aux favoris
- Paramètres
- Historique

## 📦 Dépendances Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Géolocalisation
  geolocator: ^9.0.2
  google_maps_flutter: ^2.5.0
  location: ^4.4.0
  
  # State Management
  provider: ^6.0.0
  
  # Navigation
  get: ^4.6.5
  
  # API & HTTP
  dio: ^5.3.0
  http: ^1.1.0
  
  # Stockage Local
  shared_preferences: ^2.2.0
  sqflite: ^2.3.0
  
  # UI
  flutter_svg: ^2.0.0
  
  # Permissions
  permission_handler: ^11.4.4
```

## 🔐 Permissions Requises

### Android
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### iOS
```xml
NSLocationWhenInUseUsageDescription
NSLocationAlwaysAndWhenInUseUsageDescription
NSCameraUsageDescription
NSPhotoLibraryUsageDescription
```

## 🛠️ Installation et Démarrage

### 1. Cloner le repository
```bash
git clone https://github.com/yourusername/allo-secours.git
cd allo-secours
```

### 2. Installer les dépendances
```bash
flutter pub get
```

### 3. Générer les fichiers (si nécessaire)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Lancer sur l'émulateur/appareil
```bash
flutter run
```

### 5. Build de release

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 💡 Points Clés de l'Architecture

### State Management avec Provider
- `LocationProvider`: Gère la localisation actuelle de l'utilisateur
- `ServicesProvider`: Gère la liste des services et les filtres

### API Service
- Communication avec un backend API
- Endpoints pour services, reviews, géolocalisation
- Gestion des erreurs

### Storage Service
- Sauvegarde des favoris
- Historique de recherche
- Données utilisateur

## 🔌 Intégration API

### Base URL
```
https://api.allo-secours.com
```

### Endpoints principales
```
GET /services                 # Tous les services
GET /services/:id            # Détails
GET /services/nearby         # Services à proximité
GET /services/:id/reviews    # Avis
POST /services/:id/reviews   # Ajouter un avis
```

## 🧪 Testing

Pour les tests, l'application utilise `mock_data.dart` qui fournit des données de test.

```dart
import 'package:allo_secours/utils/mock_data.dart';

// Utiliser les données de test
final services = MockData.mockServices;
```

## 📝 Conventions de Code

- **Noms de fichiers**: snake_case (`app_colors.dart`)
- **Noms de classes**: PascalCase (`HomeScreen`)
- **Noms de variables**: camelCase (`currentLocation`)
- **Formatting**: `dart format`
- **Linting**: `flutter analyze`

## 🔄 Workflow de Développement

1. Créer une branche: `git checkout -b feature/nouvelle-fonctionnalite`
2. Faire les modifications
3. Tester: `flutter test`
4. Format de code: `dart format .`
5. Analyser: `flutter analyze`
6. Commit: `git commit -m "feat: description"`
7. Push: `git push origin feature/nouvelle-fonctionnalite`
8. Créer une Pull Request

## 📱 Platforms Supportées

- ✅ Android (API 21+)
- ✅ iOS (11.0+)
- ⚠️ Web (support partiel)

## 🚨 Gestion des Erreurs

L'application possède des classes d'exception personnalisées:
- `NetworkException`: Erreurs réseau
- `ServerException`: Erreurs serveur
- `ValidationException`: Erreurs de validation
- `LocationException`: Erreurs de géolocalisation

## 🎨 Palette de Couleurs

```dart
Primary: #003D7A (Bleu foncé)
Secondary: #00A651 (Vert)
Accent: #FFC107 (Or)
Error: #D32F2F (Rouge)
Success: #4CAF50 (Vert clair)
```

## 📞 Support et Contact

Pour les questions ou problèmes, veuillez:
1. Consulter la documentation
2. Ouvrir une issue sur GitHub
3. Contacter l'équipe de développement

## 📄 License

MIT License - Voir LICENSE.md

## 🎯 Roadmap Futur

- [ ] Intégration paiement en ligne
- [ ] Notifications push
- [ ] Synchronisation cloud des données
- [ ] Support multi-langue
- [ ] Mode dark
- [ ] Prise de rendez-vous en ligne
- [ ] Intégration WhatsApp/Telegram
- [ ] Historique de visites
- [ ] Recommandations personnalisées
