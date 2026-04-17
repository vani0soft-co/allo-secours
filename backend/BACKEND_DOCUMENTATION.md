# Documentation Backend - Allo Secours

## 🚀 Installation & Démarrage

### Prérequis
- Node.js >= 14.0.0
- MongoDB >= 4.0 (local ou Atlas)
- npm ou yarn

### Installation

1. **Naviguer au dossier backend**
```bash
cd backend
```

2. **Installer les dépendances**
```bash
npm install
```

3. **Configurer les variables d'environnement**
```bash
cp .env.example .env
```

Éditer `.env` avec votre configuration:
```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/allo-secours
JWT_SECRET=your_secret_key
```

4. **Démarrer MongoDB**
```bash
# Avec Docker
docker run -d -p 27017:27017 --name mongodb mongo

# Ou localement si installé
mongod
```

5. **Remplir la base de données**
```bash
npm run seed
```

6. **Démarrer le serveur**
```bash
npm run dev  # Mode développement (avec auto-reload)
npm start    # Mode production
```

Le serveur sera accessible à `http://localhost:3000`

## 📁 Structure Backend

```
backend/
├── src/
│   ├── controllers/      # Logique métier
│   │   ├── authController.js
│   │   ├── serviceController.js
│   │   └── reviewController.js
│   ├── models/          # MongoDB Schemas
│   │   ├── User.js
│   │   ├── Service.js
│   │   └── Review.js
│   ├── routes/          # API Routes
│   │   ├── authRoutes.js
│   │   ├── serviceRoutes.js
│   │   └── reviewRoutes.js
│   ├── middlewares/     # Middleware
│   │   └── auth.js
│   ├── seeds/           # Données de test
│   │   └── seedDatabase.js
│   └── index.js         # Point d'entrée
├── package.json
├── .env.example
└── .gitignore
```

## 📚 API Endpoints

### Base URL
```
http://localhost:3000/api/v1
```

### Services

#### Récupérer tous les services
```
GET /services
Headers: none

Query Parameters:
- category: 'hospital' | 'pharmacy' | 'specialist' | 'emergency' | 'imaging'
- search: texte de recherche
- skip: nombre d'éléments à sauter (défaut: 0)
- limit: nombre d'éléments à retourner (défaut: 20)

Response (200):
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "name": "Hôpital Central",
      "category": "hospital",
      "address": "...",
      "rating": 4.5,
      "reviewCount": 250,
      "isOpen": true,
      ...
    }
  ],
  "pagination": {
    "total": 100,
    "skip": 0,
    "limit": 20
  }
}
```

#### Récupérer un service
```
GET /services/:id

Response (200):
{
  "success": true,
  "data": { ... }
}
```

#### Rechercher des services à proximité
```
POST /services/nearby
Headers: Content-Type: application/json

Body:
{
  "latitude": 48.8566,
  "longitude": 2.3522,
  "radius": 5000,          // en mètres
  "category": "hospital"   // optionnel
}

Response (200):
{
  "success": true,
  "data": [ ... ]
}
```

#### Services par catégorie
```
GET /services/category/:category

Query Parameters:
- skip: 0
- limit: 20

Response (200): même format que getAllServices
```

### Avis (Reviews)

#### Récupérer les avis d'un service
```
GET /services/:serviceId/reviews

Query Parameters:
- skip: 0
- limit: 10

Response (200):
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "rating": 5,
      "comment": "Excellent service!",
      "userName": "Jean Dupont",
      "createdAt": "2024-04-14T10:00:00Z",
      "likeCount": 5
    }
  ],
  "pagination": { ... }
}
```

#### Ajouter un avis
```
POST /services/:serviceId/reviews
Headers: 
  - Content-Type: application/json
  - Authorization: Bearer <token>

Body:
{
  "rating": 5,
  "comment": "Très bon service!"
}

Response (201):
{
  "success": true,
  "data": { ... }
}
```

#### Mettre à jour un avis
```
PUT /reviews/:reviewId
Headers: 
  - Content-Type: application/json
  - Authorization: Bearer <token>

Body:
{
  "rating": 4,
  "comment": "Bon service, service rapide"
}

Response (200): { ... }
```

#### Supprimer un avis
```
DELETE /reviews/:reviewId
Headers: Authorization: Bearer <token>

Response (200):
{
  "success": true,
  "message": "Avis supprimé avec succès"
}
```

#### Liker un avis
```
POST /reviews/:reviewId/like
Headers: Authorization: Bearer <token>

Response (200):
{
  "success": true,
  "data": { ... }
}
```

### Authentification

#### Inscription
```
POST /auth/register
Headers: Content-Type: application/json

Body:
{
  "firstName": "Giovani",
  "lastName": "Ismaël",
  "email": "giovani@example.com",
  "password": "password123",
  "passwordConfirm": "password123"
}

Response (201):
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "...",
    "firstName": "Giovani",
    "lastName": "Ismaël",
    "email": "giovani@example.com"
  }
}
```

#### Login
```
POST /auth/login
Headers: Content-Type: application/json

Body:
{
  "email": "giovani@example.com",
  "password": "password123"
}

Response (200): Même format que register
```

#### Récupérer le profil
```
GET /auth/profile
Headers: Authorization: Bearer <token>

Response (200):
{
  "success": true,
  "data": {
    "firstName": "Giovani",
    "lastName": "Ismaël",
    "email": "giovani@example.com",
    "phone": "+33...",
    "favorites": [ ... ],
    "searchHistory": [ ... ]
  }
}
```

#### Mettre à jour le profil
```
PUT /auth/profile
Headers: 
  - Content-Type: application/json
  - Authorization: Bearer <token>

Body:
{
  "firstName": "Giovani",
  "lastName": "Ismaël",
  "phone": "+33123456789"
}

Response (200): { ... }
```

#### Ajouter aux favoris
```
POST /auth/favorites/:serviceId
Headers: Authorization: Bearer <token>

Response (200):
{
  "success": true,
  "data": [ ... ] // liste des favoris
}
```

#### Retirer des favoris
```
DELETE /auth/favorites/:serviceId
Headers: Authorization: Bearer <token>

Response (200):
{
  "success": true,
  "data": [ ... ]
}
```

## 🗄️ Modèles de Données

### Service
```javascript
{
  _id: ObjectId,
  name: String,
  category: 'hospital' | 'pharmacy' | 'specialist' | 'emergency' | 'imaging',
  description: String,
  address: String,
  city: String,
  zipCode: String,
  country: String,
  coordinates: { type: 'Point', coordinates: [lon, lat] },
  phone: String,
  email: String,
  website: String,
  workingHours: String,
  isOpen: Boolean,
  rating: Number (0-5),
  reviewCount: Number,
  imageUrl: String,
  specialties: [String],
  services: [String],
  capacity: Number,
  emergencyServices: Boolean,
  verified: Boolean,
  createdAt: DateTime,
  updatedAt: DateTime
}
```

### Review
```javascript
{
  _id: ObjectId,
  service: ObjectId (ref: Service),
  user: ObjectId (ref: User),
  userName: String,
  rating: Number (1-5),
  comment: String,
  likeCount: Number,
  likes: [ObjectId],
  verified: Boolean,
  createdAt: DateTime,
  updatedAt: DateTime
}
```

### User
```javascript
{
  _id: ObjectId,
  firstName: String,
  lastName: String,
  email: String,
  password: String (hashed),
  phone: String,
  avatar: String,
  favorites: [ObjectId (ref: Service)],
  searchHistory: [{ query: String, timestamp: DateTime }],
  lastLocation: { type: 'Point', coordinates: [lon, lat] },
  role: 'user' | 'admin',
  isActive: Boolean,
  createdAt: DateTime,
  updatedAt: DateTime
}
```

## 🔐 Authentification

Le backend utilise JWT (JSON Web Tokens) pour l'authentification.

1. **Inscription/Login** retournent un token JWT
2. Les routes protégées nécessitent un header `Authorization: Bearer <token>`
3. Les tokens expirent après 7 jours (configurable)

## 🧪 Testing

```bash
# Lancer les tests
npm test

# Avec couverture
npm test -- --coverage
```

## 🚀 Déploiement

### Heroku
```bash
heroku create allo-secours-backend
git push heroku main
```

### Railway
```bash
railway init
railway up
```

### Self-hosted
1. Configurer une instance serveur (Ubuntu, etc.)
2. Installer Node.js et MongoDB
3. Cloner le repository
4. Configurer les variables d'environnement
5. Lancer avec PM2: `pm2 start src/index.js`

## 📝 Notes Importantes

- Tous les endpoints retournent un format JSON uniforme
- Les dates au format ISO 8601
- Pagination par défaut: skip=0, limit=20
- Les recherches géospatiales utilisent MongoDB GeoJSON
- Les mots de passe sont hashés avec bcrypt
- Les tokens JWT expirent après 7 jours

## 🔗 Liens Utiles

- [Express Documentation](https://expressjs.com)
- [Mongoose Documentation](https://mongoosejs.com)
- [MongoDB Documentation](https://docs.mongodb.com)
- [JWT Documentation](https://jwt.io)

---

Pour toute question, consultez la documentation du projet ou ouvrez une issue.
