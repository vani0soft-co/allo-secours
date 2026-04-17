# Backend Allo Secours

Backend Node.js/Express pour l'application mobile Allo Secours.

## 🚀 Quick Start

```bash
# Installer les dépendances
npm install

# Configurer les variables d'environnement
cp .env.example .env

# Démarrer MongoDB
docker run -d -p 27017:27017 --name mongo mongo:latest

# Remplir la base de données
npm run seed

# Lancer le serveur
npm run dev
```

Le serveur sera disponible sur `http://localhost:3000`

## 📚 Documentation

- **[BACKEND_DOCUMENTATION.md](./BACKEND_DOCUMENTATION.md)** - API complète et endpoints
- **[../BACKEND_INTEGRATION_GUIDE.md](../BACKEND_INTEGRATION_GUIDE.md)** - Guide d'intégration frontend/backend

## 🏗️ Architecture

```
src/
├── controllers/      # Logique métier
├── models/          # Schémas MongoDB
├── routes/          # Routes API
├── middlewares/     # Middlewares (auth, etc.)
├── seeds/           # Données de test
└── index.js         # Point d'entrée
```

## 📦 Stack Technologique

- **Express.js** - Framework web
- **MongoDB** - Base de données
- **Mongoose** - ODM pour MongoDB
- **JWT** - Authentification
- **bcryptjs** - Hashage des mots de passe

## 🔌 API Endpoints

Base URL: `/api/v1`

### Services
- `GET /services` - Tous les services
- `GET /services/:id` - Détails
- `POST /services/nearby` - Services proches
- `GET /services/category/:category` - Par catégorie

### Avis
- `GET /services/:serviceId/reviews` - Avis d'un service
- `POST /services/:serviceId/reviews` - Ajouter un avis
- `PUT /reviews/:reviewId` - Mettre à jour
- `DELETE /reviews/:reviewId` - Supprimer
- `POST /reviews/:reviewId/like` - Liker

### Authentification
- `POST /auth/register` - Inscription
- `POST /auth/login` - Connexion
- `GET /auth/profile` - Profil (protégé)
- `POST /auth/favorites/:serviceId` - Ajouter aux favoris

## 🗄️ Modèles de Données

### Service
```javascript
{
  name, category, description, address, city, zipCode,
  coordinates, phone, email, workingHours, isOpen,
  rating, reviewCount, specialties, services
}
```

### Review
```javascript
{
  service, user, userName, rating, comment,
  likeCount, verified, timestamps
}
```

### User
```javascript
{
  firstName, lastName, email, password, phone,
  favorites, searchHistory, lastLocation, role
}
```

## 🧪 Tests

```bash
npm test
```

## 🚀 Déploiement

### Heroku
```bash
heroku create allo-secours-api
git push heroku main
```

### Environnement de Production
```bash
NODE_ENV=production npm start
```

## 📞 Support

Voir [BACKEND_DOCUMENTATION.md](./BACKEND_DOCUMENTATION.md) pour plus de détails.

---

**Status**: ✅ Fonctionnel
**Dernière mise à jour**: 14 Avril 2024
