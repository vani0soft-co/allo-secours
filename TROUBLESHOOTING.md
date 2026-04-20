# 🔧 Guide de Dépannage - Allo Secours

## 📋 Problèmes Courants et Solutions

### 1. ❌ Backend ne démarre pas

#### Erreur: "Port 3000 already in use"
```bash
# Trouver le processus utilisant le port
lsof -i :3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows

# Tuer le processus
kill -9 <PID>  # macOS/Linux
taskkill /PID <PID> /F  # Windows
```

#### Erreur: "connect ECONNREFUSED 127.0.0.1:27017"
```bash
# MongoDB n'est pas démarré
# Lancer avec Docker
docker run -d -p 27017:27017 mongo:latest

# Ou localement
mongod
```

#### Erreur: "npm ERR! Cannot find module"
```bash
# Réinstaller les dépendances
rm -rf node_modules package-lock.json
npm install
```

---

### 2. ❌ MongoDB ne se connecte pas

#### Erreur: "MongoServerSelectionError"
```bash
# Vérifier que MongoDB est en cours d'exécution
sudo systemctl status mongod  # Linux
brew services list | grep mongodb  # macOS

# Ou avec Docker
docker ps | grep mongo
docker logs allo-secours-mongo
```

#### Erreur: "Authentication failed"
```bash
# Vérifier les identifiants dans .env
cat .env

# Réinitialiser MongoDB (attention: supprime les données)
docker rm allo-secours-mongo
docker run -d -p 27017:27017 mongo:latest
```

---

### 3. ❌ Frontend Flutter ne se connecte pas au backend

#### L'app lance mais pas de données

**Vérifier 1: Le backend fonctionne**
```bash
# Tester l'endpoint health
curl http://localhost:3000/health

# Ou via le navigateur
http://localhost:3000/health
```

**Vérifier 2: L'URL est correcte dans l'app**
```dart
// lib/services/api_service.dart
final String _baseUrl = 'http://localhost:3000/api/v1';

// Pour Android Emulator
// final String _baseUrl = 'http://10.0.2.2:3000/api/v1';

// Pour iOS Simulator
// final String _baseUrl = 'http://localhost:3000/api/v1';
```

**Vérifier 3: CORS est activé**
```javascript
// backend/src/index.js
const corsOptions = {
  origin: '*',  // À restreindre en production
  credentials: true,
};
```

#### Erreur: "Failed to load image from network"

**Problème**: Les URLs d'images sont invalides

```bash
# Vérifier que les URLs dans la BD sont valides
# Éditer backend/src/seeds/seedDatabase.js

# Ou tester l'endpoint
curl http://localhost:3000/api/v1/services
```

---

### 4. ❌ Erreurs d'Authentification

#### Erreur: "Invalid token"

```bash
# Vérifier que JWT_SECRET est le même
# backend/.env
# lib/services/api_service.dart

# Réinitialiser les données de test
npm run seed
```

#### Erreur: "Token not found"

```dart
// shared_preferences ne sauvegarde pas le token?
// Vérifier les permissions
// android/app/src/main/AndroidManifest.xml:
// <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

---

### 5. ⚠️ Problèmes de Géolocalisation

#### Erreur: "Permission denied"

**Android**:
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**iOS**:
```xml
<!-- ios/Runner/Info.plist -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Nous utilisons votre localisation pour trouver les services de santé proches</string>
```

#### Erreur: "Location always null"

```bash
# Sur l'émulateur/simulateur
# Définir manuellement la localisation

# Android Emulator
adb emu geo fix 48.8566 2.3522  # Paris

# iOS Simulator
Simulator > Features > Location > Custom Location
# Latitude: 48.8566
# Longitude: 2.3522
```

---

### 6. ❌ Construire l'APK/IPA échoue

#### Flutter build Android

```bash
# Nettoyer le build
flutter clean

# Reconstruire
flutter pub get
flutter pub upgrade

# Générer APK
flutter build apk --release

# Ou AAB
flutter build appbundle --release
```

#### Flutter build iOS

```bash
# Mettre à jour les pods
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..

# Reconstruire
flutter pub get
flutter build ios --release
```

---

### 7. 🚨 Voir les Logs

#### Backend Node.js

```bash
# En développement (avec npm run dev)
# Les logs s'affichent automatiquement

# Sauvegarder les logs
npm run dev > backend.log 2>&1

# Voir les logs
tail -f backend.log
```

#### MongoDB

```bash
# Logs du container Docker
docker logs -f allo-secours-mongo

# Logs MongoDB
docker exec allo-secours-mongo mongod --logpath /data/db/mongodb.log
```

#### Flutter

```bash
# Affichage détaillé
flutter run -v

# Logs uniquement
flutter logs
```

---

### 8. 🔄 Réinitialiser Complètement

```bash
# ==========================================
# RESET COMPLET (attention: supprime tout)
# ==========================================

# 1. Arrêter tous les services
pkill -f "npm run dev"
docker stop allo-secours-mongo

# 2. Supprimer les conteneurs et volumes
docker rm allo-secours-mongo
docker volume rm allo-secours_mongodb_data

# 3. Nettoyer Flutter
flutter clean

# 4. Réinstaller tout
cd backend
rm -rf node_modules package-lock.json
npm install
npm run seed

# 5. Relancer
cd ..
npm run dev (dans backend/)
flutter run
```

---

### 9. 📊 Vérifier la Base de Données

```bash
# Se connecter à MongoDB
mongo  # ou mongosh

# Sélectionner la base
use allo-secours

# Voir les collections
show collections

# Voir les services
db.services.find()

# Voir les utilisateurs
db.users.find()

# Compter les services
db.services.countDocuments()
```

---

### 10. 🌐 Tester les Endpoints manuellement

```bash
# Récupérer tous les services
curl http://localhost:3000/api/v1/services

# Récupérer un service spécifique
curl http://localhost:3000/api/v1/services/SERVICE_ID

# Rechercher les services proches
curl -X POST http://localhost:3000/api/v1/services/nearby \
  -H "Content-Type: application/json" \
  -d '{"latitude": 48.8566, "longitude": 2.3522, "radius": 5}'

# S'inscrire
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"firstName": "John", "lastName": "Doe", "email": "john@example.com", "password": "password123"}'
```

---

### 11. 📱 Déboguer sur Appareil Réel

```bash
# Android
adb devices  # Voir les appareils connectés
flutter run -d <device_id>

# iOS
open -a Simulator  # Lancer le simulateur
flutter run -d 'iPhone 15'
```

---

### 12. 💾 Sauvegarde et Restauration

```bash
# Exporter les services MongoDB
mongoexport --db allo-secours --collection services --out services.json

# Réimporter
mongoimport --db allo-secours --collection services --file services.json

# Avec Docker
docker exec allo-secours-mongo mongoexport --db allo-secours --collection services --out /data/db/services.json
```

---

## 🆘 Besoin d'Aide?

1. Consulter la documentation complète:
   - [BACKEND_DOCUMENTATION.md](backend/BACKEND_DOCUMENTATION.md)
   - [BACKEND_INTEGRATION_GUIDE.md](BACKEND_INTEGRATION_GUIDE.md)

2. Vérifier les logs avec verbosité:
   ```bash
   flutter run -v
   npm run dev
   docker logs <container_id>
   ```

3. Chercher dans les issues sur GitHub

4. Vérifier les versions:
   ```bash
   node --version
   npm --version
   flutter --version
   dart --version
   docker --version
   ```

---

**Dernier recours**: Réinitialiser complètement (voir section 8)

🚀 Bon dépannage!
