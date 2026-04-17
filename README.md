# Allo Secours - Application Mobile

Application mobile Flutter pour la géolocalisation des hôpitaux, pharmacies et autres services de santé essentiels.

## Fonctionnalités

- 📍 **Géolocalisation**: Localisation en temps réel de votre position
- 🏥 **Hôpitaux**: Trouver les hôpitaux les plus proches
- 💊 **Pharmacies**: Localisez les pharmacies à proximité
- 🚑 **Urgences**: Accès rapide aux services d'urgence 24h/24
- ⭐ **Évaluations**: Consultez les avis d'autres utilisateurs
- 🗺️ **Cartes**: Visualisation des services sur Google Maps
- ❤️ **Favoris**: Sauvegardez vos services préférés

## Architecture

```
lib/
├── config/          # Configuration (couleurs, routes)
├── models/          # Modèles de données
├── providers/       # Gestion d'état (Provider)
├── screens/         # Écrans de l'application
├── services/        # Services (API)
├── widgets/         # Widgets réutilisables
└── main.dart        # Point d'entrée
```

## Installation

### Prérequis

- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- Android Studio / Xcode

### Étapes

1. Clone le projet:
```bash
git clone https://github.com/yourusername/allo-secours.git
cd allo-secours
```

2. Installer les dépendances:
```bash
flutter pub get
```

3. Générer les fichiers de configuration:
```bash
flutter pub run build_runner build
```

4. Lancer l'application:
```bash
flutter run
```

## Configuration

### Google Maps API

Ajouter votre clé API Google Maps dans:
- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/Info.plist`

### Variables d'environnement

Créer un fichier `.env` à la racine:
```
API_BASE_URL=https://api.allo-secours.com
```

## Dépendances Principales

- **getx**: Navigation et gestion d'état
- **provider**: State management
- **geolocator**: Géolocalisation
- **google_maps_flutter**: Intégration Google Maps
- **dio**: Requêtes HTTP
- **sqflite**: Base de données locale

## Permissions Requises

### Android
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `INTERNET`

### iOS
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`

## Structure de l'API

L'application communique avec une API backend:

```
GET /services                 - Récupérer tous les services
GET /services/:id            - Détails d'un service
GET /services/nearby         - Services proches
GET /services/:id/reviews    - Avis d'un service
POST /services/:id/reviews   - Ajouter un avis
```

## Development

### Code Style

- Utiliser les conventions Dart/Flutter
- Nommer les fichiers en snake_case
- Nommer les classes en PascalCase
- Formater avec `dart format`

### Build Release

Android:
```bash
flutter build apk --release
flutter build appbundle --release
```

iOS:
```bash
flutter build ios --release
```

## Contribuer

1. Créer une branche: `git checkout -b feature/AmazingFeature`
2. Commiter les changements: `git commit -m 'Add some AmazingFeature'`
3. Pousser vers la branche: `git push origin feature/AmazingFeature`
4. Ouvrir une Pull Request

## Licence

Ce projet est sous licence MIT.

## Support

Pour les questions ou problèmes, ouvrir une issue sur GitHub.

## Version

v1.0.0
