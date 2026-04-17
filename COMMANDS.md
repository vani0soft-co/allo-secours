# Commandes Utiles - Allo Secours

## 🚀 Démarrage

### Installation de base
```bash
# Cloner le projet
git clone https://github.com/yourusername/allo-secours.git
cd allo-secours

# Installer les dépendances
flutter pub get

# Générer les fichiers (si nécessaire)
flutter pub run build_runner build
```

### Lancer l'application
```bash
# Sur émulateur/appareil connecté
flutter run

# Mode debug
flutter run --debug

# Mode release
flutter run --release

# Sur un appareil spécifique
flutter run -d <device-id>

# Lister les appareils disponibles
flutter devices
```

## 🧹 Nettoyage & Maintenance

```bash
# Nettoyer le cache
flutter clean

# Récupérer les dépendances à nouveau
flutter pub get

# Mise à jour des dépendances
flutter pub upgrade

# Vérifier les dépendances obsolètes
flutter pub outdated

# Formater le code
dart format lib/

# Analyser le code (linting)
flutter analyze

# Fix automatiques
dart fix --apply
```

## 🏗️ Build

### Android
```bash
# APK Debug
flutter build apk --debug

# APK Release
flutter build apk --release

# App Bundle (pour Play Store)
flutter build appbundle --release

# Signer APK
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
  -keystore ~/key.keystore app-release-unsigned.apk key
```

### iOS
```bash
# iOS Debug
flutter build ios --debug

# iOS Release
flutter build ios --release

# Ouvrir le projet Xcode
open ios/Runner.xcworkspace

# Archive pour App Store (depuis Xcode)
# Product > Archive
```

### Web
```bash
# Build web
flutter build web

# Servir localement
flutter run -d web-server
```

## 🧪 Tests

```bash
# Lancer tous les tests
flutter test

# Tests spécifiques
flutter test test/models/service_model_test.dart

# Avec couverture
flutter test --coverage

# Générer rapport couverture
lcov -l coverage/lcov.info

# Watcher mode
flutter test --watch
```

## 📊 Analyse & Debug

```bash
# Analyser le code
flutter analyze

# Obtenir des infos de build
flutter pub publish --dry-run

# Afficher la taille des assets
flutter build apk --analyze-size

# Debugger en ligne de commande
flutter attach

# Hot reload (en exécution)
r (reload)
R (hot restart)
q (quit)
```

## 🔍 Logs & Debugging

```bash
# Afficher les logs
flutter logs

# Filtrer les logs
flutter logs --grep "MyApp"

# Verbose mode
flutter run -v

# Dumper les informations l'apparatus
flutter doctor

# Détails sur la configuration
flutter doctor -v
```

## 📱 Appareils & Émulateurs

```bash
# Lister les appareils
flutter devices

# Créer un émulateur Android
flutter emulators --create --name my_emulator

# Lancer émulateur Android
flutter emulators --launch my_emulator

# Lancer simulateur iOS
open -a Simulator

# Connecter appareil USB
# (généralement automatique, sinon: adb devices)
```

## 🔐 Certificats & Clés

### Générer une clé de signature (Android)
```bash
keytool -genkey -v -keystore ~/key.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias key
```

### Voir les infos de certificat
```bash
keytool -list -v -keystore ~/key.keystore
```

## 🎯 Gestion des fichiers

```bash
# Voir la structure des fichiers
tree lib/

# Compter les lignes de code
find lib -name "*.dart" | xargs wc -l

# Trouver les fichiers TODO
grep -r "TODO" lib/

# Finder les imports inutilisés
flutter pub get && dart analyze
```

## 🚀 Intégration Continue (CI/CD)

### GitHub Actions
```bash
# Lancer les actions localement (avec act)
act -l
act --job <job-id>
```

### Déploiement
```bash
# Play Store (via fastlane)
fastlane android deploy

# App Store (via fastlane)
fastlane ios deploy

# Firebase Hosting
firebase deploy
```

## 📦 Gestion des dépendances

```bash
# Ajouter une dépendance
flutter pub add package_name

# Ajouter en dev
flutter pub add --dev package_name

# Retirer une dépendance
flutter pub remove package_name

# Mettre à jour une dépendance
flutter pub upgrade package_name

# Voir les infos d'une package
flutter pub information package_name
```

## 🌐 Mise en place d'API

```bash
# Proxy HTTP (pour déboguer les requêtes)
# Ajouter dans ApiService:
# Dio dio = Dio();
# dio.httpClientAdapter = HttpClientAdapter()
```

## 📝 Commandes Personnalisées

Vous pouvez ajouter des scripts dans `pubspec.yaml`:

```yaml
scripts:
  format: dart format lib/
  analyze: flutter analyze
  test: flutter test
  build:android: flutter build apk --release
  build:ios: flutter build ios --release
```

Puis exécuter:
```bash
dart run format
```

## 🔧 Troubleshooting

```bash
# Réinstaller Flutter
flutter clean
flutter pub get

# Mettre à jour Flutter
flutter upgrade

# Channel switching
flutter channel stable  # ou dev, beta, master
flutter upgrade

# Réinitialiser complètement
rm -rf .dart_tool/
rm pubspec.lock
flutter clean
flutter pub get
```

## 📚 Documentation Générale

```bash
# Ouvrir la documentation
flutter --help
flutter run --help
dart --help

# Voir la version actuelle
flutter --version
```

---

💡 **Astuce**: Créez des alias dans votre `.bashrc` ou `.zshrc`:
```bash
alias fclean="flutter clean && flutter pub get"
alias frun="flutter run"
alias ftest="flutter test"
alias fanal="flutter analyze && dart format lib/"
```
