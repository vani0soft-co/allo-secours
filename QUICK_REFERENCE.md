# ⚡ Quick Reference - Commandes Essentielles

## 🎯 Les Commandes Que Vous Utiliserez Le Plus

### 1️⃣ Démarrer l'App (Choisir Une Option)

#### Option A: Script Automatique (Recommandé)
```bash
# Windows (PowerShell)
.\START.ps1

# Mac/Linux
bash START.sh
```

#### Option B: Manuel Complet
```bash
# Terminal 1: Lancer la base de données et le backend
docker-compose up -d
cd backend
npm install
npm run seed
npm run dev

# Terminal 2: Lancer le frontend
flutter run
```

#### Option C: Docker Compose Only
```bash
docker-compose up -d
cd backend && npm run seed && npm run dev
```

---

### 2️⃣ Frontend Commands

```bash
# Récupérer les dépendances
flutter pub get

# Lancer l'app
flutter run

# Lancer avec logs détaillés
flutter run -v

# Tester
flutter test

# Vérifier la qualité du code
flutter analyze

# Formatter du code
dart format lib/

# Générer APK (Android)
flutter build apk --release

# Générer IPA (iOS)
flutter build ios --release
```

---

### 3️⃣ Backend Commands

```bash
# Depuis le dossier backend/
cd backend

# Installer
npm install

# Démarrer en développement
npm run dev

# Remplir la base de données de test
npm run seed

# Tests
npm test

# Linter
npm run lint

# Build
npm run build

# Production
npm start
```

---

### 4️⃣ Docker Commands

```bash
# Lancer tout
docker-compose up -d

# Arrêter tout
docker-compose down

# Voir les logs
docker-compose logs -f

# Supprimer tout (⚠️ données perdues!)
docker-compose down -v

# Logs MongoDB seulement
docker logs -f allo-secours-mongo

# Logs Backend seulement
docker logs -f allo-secours-backend
```

---

### 5️⃣ API Testing (Curl)

```bash
# Récupérer tous les services
curl http://localhost:3000/api/v1/services

# Récupérer un service spécifique
curl http://localhost:3000/api/v1/services/SERVICE_ID

# Chercher services proches (Paris)
curl -X POST http://localhost:3000/api/v1/services/nearby \
  -H "Content-Type: application/json" \
  -d '{"latitude": 48.8566, "longitude": 2.3522, "radius": 5}'

# S'inscrire
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"firstName": "John", "lastName": "Doe", "email": "john@example.com", "password": "password123"}'

# Se connecter
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "giovani@example.com", "password": "password123"}'

# Health check
curl http://localhost:3000/health
```

---

### 6️⃣ MongoDB Commands

```bash
# Connexion locale
mongo

# Ou avec mongosh
mongosh

# Sélectionner la base
use allo-secours

# Voir les collections
show collections

# Voir tous les services
db.services.find()

# Voir les utilisateurs
db.users.find()

# Compter les services
db.services.countDocuments()

# Exporter les services
mongoexport --db allo-secours --collection services --out services.json

# Réimporter les services
mongoimport --db allo-secours --collection services --file services.json
```

---

### 7️⃣ Git Commands

```bash
# Voir le status
git status

# Ajouter des fichiers
git add .

# Commit
git commit -m "Description du changement"

# Push
git push origin main

# Voir l'historique
git log --oneline

# Revert un changement
git revert <commit-hash>
```

---

### 8️⃣ Debugging

```bash
# Flutter logs détaillé
flutter run -v

# Backend logs en temps réel
npm run dev  # Déjà en détail

# Voir tout les appareils/émulateurs disponibles
flutter devices

# Reset complet Flutter
flutter clean && flutter pub get

# Reset complet Backend
cd backend && rm -rf node_modules && npm install
```

---

### 9️⃣ Nettoyage & Réinitialisation

```bash
# Reset Flutter complètement
flutter clean
flutter pub get

# Reset Backend complètement
cd backend
rm -rf node_modules package-lock.json
npm install

# Reset MongoDB
docker-compose down -v
docker-compose up -d

# Reset tout le projet
docker-compose down -v
flutter clean
cd backend && rm -rf node_modules
# Puis relancer: docker-compose up -d && cd backend && npm install && npm run seed
```

---

### 🔟 Configuration Rapide

```bash
# Changer API URL pour emulateur Android
# Éditer: lib/services/api_service.dart
# Remplacer: final String _baseUrl = 'http://localhost:3000/api/v1';
# Par: final String _baseUrl = 'http://10.0.2.2:3000/api/v1';

# Ajouter des variables d'environnement
cp backend/.env.example backend/.env
# Éditer: backend/.env
```

---

## 📱 Ports & URLs

| Service | Port | URL | Commande |
|---------|------|-----|----------|
| Backend | 3000 | http://localhost:3000 | `npm run dev` |
| API | 3000 | http://localhost:3000/api/v1 | - |
| MongoDB | 27017 | mongodb://localhost:27017 | `docker run -d -p 27017:27017 mongo:latest` |
| Flutter | variable | - | `flutter run` |
| Health | 3000 | http://localhost:3000/health | - |

---

## 🔐 Identifiants de Test

```
Email: giovani@example.com
Mot de passe: password123
```

---

## 📊 Services de Test

```
1. Hôpital Central Paris (hospital)
2. Pharmacie Santé Plus (pharmacy)
3. Dr. Ahmed Cardiologue (specialist)
4. SAMU Urgences 15 (emergency)
5. Imagerie Médicale Ouest (imaging)
```

---

## ⏱️ Temps Estimés

| Action | Temps |
|--------|-------|
| Premier démarrage (tout) | 5-10 min |
| Démarrages suivants | 2-3 min |
| Build APK release | 5-10 min |
| Build IPA release | 10-15 min |
| Tests complets | 15-20 min |

---

## 🚨 Problèmes Courants

### Le port 3000 est déjà utilisé
```bash
lsof -i :3000  # Voir le processus
kill -9 <PID>  # Tuer le processus
```

### MongoDB ne démarre pas
```bash
docker run -d -p 27017:27017 mongo:latest
# Ou vérifier: docker ps
```

### App ne se connecte pas au backend
```bash
# Vérifier que backend est démarré
curl http://localhost:3000/health

# Vérifier l'URL dans l'app
# lib/services/api_service.dart:
# _baseUrl = 'http://localhost:3000/api/v1'  # macOS/iOS Simulator
# _baseUrl = 'http://10.0.2.2:3000/api/v1'   # Android Emulator
```

### Tokens expirés
```bash
# Données de test invalidées?
npm run seed  # Réinitialiser
flutter run   # Relancer l'app
```

---

## 📚 Documentation

Pour plus de détails, voir:
- **GETTING_STARTED.md** - Comment commencer
- **TROUBLESHOOTING.md** - Problèmes courants
- **BACKEND_INTEGRATION_GUIDE.md** - Configuration détaillée
- **DEPLOYMENT_CHECKLIST.md** - Avant production

---

**Bookmark this page!** ⭐

Copier-coller quand vous en avez besoin.

🚀 Happy Coding!
