# Guide d'Intégration Backend-Frontend

## 📚 Vue d'ensemble

Ce guide explique comment intégrer et tester l'intégration entre le backend Node.js/Express/MongoDB et l'application Flutter.

## 🚀 Étapes d'Installation

### 1. Démarrer MongoDB

**Avec Docker (Recommandé)**:
```bash
docker run -d -p 27017:27017 --name allo-secours-mongo mongo:latest
```

**Ou localement**:
```bash
mongod
```

**Vérifier la connexion**:
```bash
mongo
> use allo-secours
> db.services.count()  // Devrait retourner 0 initialement
```

### 2. Configurer et Démarrer le Backend

```bash
# Naviguer dans le dossier backend
cd backend

# Installer les dépendances
npm install

# Précfigurer .env
cp .env.example .env
# Éditer .env si nécessaire (port, config MongoDB, etc.)

# Remplir la base de données avec les données initiales
npm run seed

# Démarrer le serveur
npm run dev
```

**Résultat attendu**:
```
✓ Connecté à MongoDB
✓ 5 services ajoutés
✓ Utilisateur de test créé: giovani@example.com

╔════════════════════════════════════════╗
║    Allo Secours Backend Server        ║
║    Serveur lancé sur port 3000        ║
║    Env: development                   ║
╚════════════════════════════════════════╝
```

### 3. Tester le Backend

**Health Check**:
```bash
curl http://localhost:3000/health
```

**Récupérer les services**:
```bash
curl http://localhost:3000/api/v1/services?limit=2
```

**Réponse attendue**:
```json
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "name": "Hôpital Central Paris",
      "category": "hospital",
      "rating": 0,
      "reviewCount": 0,
      ...
    }
  ]
}
```

### 4. Configurer le Frontend

**Modifier `lib/services/api_service.dart`**:

L'URL de base est déjà configurée pour localhost:
```dart
static const String _baseUrl = 'http://localhost:3000/api/v1';
```

**Pour les appareils/émulateurs Android**:
```dart
// Utiliser cette URL pour accéder au serveur depuis Android
// C'est l'IP du machine host depuis l'émulateur
static const String _baseUrl = 'http://10.0.2.2:3000/api/v1';
```

**Pour les appareils iOS**:
```dart
// Sur iOS simulateur, utiliser localhost directement
static const String _baseUrl = 'http://localhost:3000/api/v1';
```

**Pour les appareils physiques**:
```dart
// Trouver l'IP de votre machine (ex: 192.168.x.x)
static const String _baseUrl = 'http://192.168.1.100:3000/api/v1';
```

### 5. Démarrer l'Application Flutter

```bash
# Dans le dossier principal
flutter run
```

## 🧪 Tests d'Intégration

### Test 1: Charger la liste des services

1. Ouvrir l'app
2. Accéder à l'écran "Services"
3. Vérifier que 5 services s'affichent

**Logs attendus**:
```
I: ✓ Services chargés avec succès
```

### Test 2: Rechercher un service

1. Dans l'écran Services
2. Taper "Hôpital" dans la barre de recherche
3. Vérifier que les résultats se filtrent

### Test 3: Récupérer les détails

1. Cliquer sur un service
2. Vérifier que les détails s'affichent correctement

### Test 4: Services à proximité

1. Aller à l'écran "Urgences"
2. L'app demande la permission de localisation
3. Accepter la permission
4. Les urgences à proximité s'affichent

### Test 5: Avis

1. Ouvrir les détails d'un service
2. Scroller vers les avis
3. Les avis s'affichent correctement

### Test 6: Authentification

**Inscription**:
1. Aller au profil
2. S'inscrire avec:
   - Email: `test@example.com`
   - Mot de passe: `password123`
3. Être redirigé vers l'accueil

**Connexion**:
1. Se déconnecter
2. Se connecter avec les identifiants précédents
3. Être redirigé vers l'accueil

## 📊 Commandes de Développement

### Backend

```bash
# Démarrer en mode dev (avec auto-reload)
npm run dev

# Démarrer en production
npm start

# Remplir la base de données
npm run seed

# Lancer les tests
npm test

# Vérifier le linting
npm run lint
```

### Frontend

```bash
# Lancer avec logs détaillés
flutter run -v

# Lancer sur un appareil spécifique
flutter run -d <device-id>

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## 🔍 Debugging

### Activer la journalisation Dio

```dart
// Dans ApiService, ajouter:
_dio.interceptors.add(
  LoggingInterceptor(), // ou utiliser pretty_dio_logger
);
```

### Vérifier les requêtes réseau

**Android**:
Utiliser Android Studio Device Monitor ou :
```bash
adb logcat | grep -i dio
```

**iOS**:
Utiliser Xcode Console ou Network Profile dans Safari

### Problèmes Courants

**Erreur: "Impossible de se connecter au serveur"**
- Vérifier que le backend est lancé: `curl http://localhost:3000/health`
- Vérifier l'URL de base dans `api_service.dart`
- Si sur Android émulateur: utiliser `10.0.2.2` au lieu de `localhost`

**Erreur: "Impossible de se connecter à MongoDB"**
- Vérifier que MongoDB est lancé: `mongo`
- Vérifier la connexion string dans `.env`
- Utiliser `docker ps` pour vérifier le container

**Erreur: "Services non trouvés (liste vide)"**
- Vérifier que la seed a bien fonctionné
- Re-lancer: `npm run seed`
- Vérifier directement dans MongoDB: `db.services.count()`

## 📱 Déploiement

### Backend Déploiement

**Heroku**:
```bash
cd backend
heroku create allo-secours-api
git push heroku main
heroku config:set MONGODB_URI=<your_mongo_atlas_uri>
```

**Railway/Render**:
Voir la documentation spécifique de ces plateformes

### Frontend Déploiement

**Play Store**:
```bash
flutter build appbundle --release
# Upload via Play Console
```

**App Store**:
```bash
flutter build ios --release
# Archive et upload via Xcode
```

## 🔐 Configuration de Production

**Backend (.env)**:
```env
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/allo-secours
JWT_SECRET=your_strong_secret_key_here
CORS_ORIGIN=https://yourdomain.com
```

**Frontend (api_service.dart)**:
```dart
static const String _baseUrl = 'https://api.yourdomain.com/api/v1';
```

## 📞 Support

Pour des problèmes d'intégration:
1. Vérifier la documentation backend: `backend/BACKEND_DOCUMENTATION.md`
2. Vérifier les logs du serveur: `npm run dev` affiche les erreurs
3. Consulter la documentation Flutter/Dart
4. Ouvrir une issue sur le repository

## 📝 Checklist d'Intégration

- [ ] MongoDB lancé et fonctionnelle
- [ ] Backend installé et démarré (`npm run dev`)
- [ ] Base de données peuplée (`npm run seed`)
- [ ] API répond au health check (`curl localhost:3000/health`)
- [ ] Frontend pointant vers la bonne URL API
- [ ] App Flutter peut charger les services
- [ ] Authentification fonctionne
- [ ] Géolocalisation fonctionne
- [ ] Avis/commentaires fonctionnent

---

Vous êtes prêt! 🎉
