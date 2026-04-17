# 🚀 Checklist de Déploiement - Allo Secours

## ✅ Pre-Deployment Checklist

### 1. Préparation du Code

- [ ] Tous les TODOs supprimés ou documentés
- [ ] Pas de console.log() en production
- [ ] Pas de TODO, FIXME, HACK comments
- [ ] Code formaté et linted

```bash
# Flutter
dart format lib/
flutter analyze

# Backend
npm run lint
npm run format
```

---

### 2. Configuration

#### Backend

- [ ] `.env` sécurisé (clés secrètes fortes)
- [ ] `NODE_ENV=production`
- [ ] `MONGODB_URI` pointe vers production BD
- [ ] `JWT_SECRET` est fort et unique
- [ ] Port configuré correctement

```env
# .env (production)
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/allo-secours
JWT_SECRET=<très-long-secret-aléatoire>
JWT_EXPIRY=7d
API_VERSION=v1
CORS_ORIGIN=https://yourdomain.com
```

#### Frontend

- [ ] API URL pointe vers serveur production
- [ ] Pas d'URLs localhost en production
- [ ] Analytics configurés
- [ ] Crashlytics configurés (optionnel)

```dart
// lib/services/api_service.dart
const String _baseUrl = 'https://api.allo-secours.com/api/v1';
```

---

### 3. Sécurité

- [ ] HTTPS activé pour toutes les requêtes API
- [ ] CORS correctement configuré
- [ ] Helmet middleware en place
- [ ] Rate limiting implémenté
- [ ] Input validation en place
- [ ] SQL Injection protection en place (Mongoose)
- [ ] Pas de secrets en git

```bash
# Vérifier les secrets en git
git log -p | grep -i "password\|secret\|key"
```

- [ ] `.gitignore` complet

```
.env
.env.local
node_modules/
build/
dist/
```

---

### 4. Tests

#### Backend

- [ ] Tous les tests passent

```bash
npm test
npm run test:coverage
```

- [ ] Tests de charge effectués
- [ ] Tests de sécurité effectués (OWASP)

#### Frontend

- [ ] Tests unitaires passent

```bash
flutter test
```

- [ ] Tests de build passent

```bash
# iOS
flutter build ios --release

# Android
flutter build appbundle --release
```

---

### 5. Base de Données

- [ ] Migration v1 → production complète
- [ ] Backup de production en place
- [ ] MongoDB index optimisés
- [ ] Authentification BD activée
- [ ] Réplication/backup configuré

```bash
# MongoDB Atlas
# ✓ Cluster créé
# ✓ WhiteList IP configured
# ✓ Backup enabled
# ✓ Monitoring enabled
```

---

### 6. Performance

#### Backend

- [ ] Caching implémenté (Redis optionnel)
- [ ] Compression gzip activée
- [ ] CDN configuré pour les assets
- [ ] Database indexes optimisés

```bash
# Tester la compression
curl -I -H "Accept-Encoding: gzip" http://localhost:3000/api/v1/services
```

#### Frontend

- [ ] Lazy loading des images
- [ ] Bundle size < 50MB
- [ ] Performance metrics < 2s load time

```bash
flutter build apk --release --analyze-size
```

---

### 7. Monitoring & Logs

- [ ] Sentry/Crashlytics configuré
- [ ] Service d'alertes en place
- [ ] Logs centralisés (ELK, DataDog, etc.)
- [ ] Health checks configurés

```bash
# Health check du backend
curl https://api.allo-secours.com/health
```

---

### 8. Déploiement Backend

### Option A: Heroku

```bash
# ✓ Heroku account configuré
# ✓ Heroku CLI installé

heroku login
heroku create allo-secours-api
git push heroku main

# Configurer les variables
heroku config:set NODE_ENV=production
heroku config:set MONGODB_URI=<mongodb-atlas-uri>
heroku config:set JWT_SECRET=<secret>

# Vérifier
heroku logs -t
heroku open
```

### Option B: Railway

```bash
# ✓ Railway account
# ✓ Railway CLI

railway init
railway up

# Logs
railway logs
```

### Option C: AWS/GCP/Azure

- [ ] VPC/Network configuré
- [ ] Load balance configuré
- [ ] Auto-scaling configuré
- [ ] Health checks configuré
- [ ] SSL/TLS configuré

### Option D: Docker Compose (Production)

```bash
docker-compose -f docker-compose.yml up -d

# Vérifier
docker ps
docker logs allo-secours-backend
```

---

### 9. Déploiement Frontend

#### Play Store (Android)

```bash
# Générer l'App Bundle
flutter build appbundle --release

# Vérifier
cd build/app/outputs/bundle/release/
ls -la app-release.aab

# Charger sur Play Store Console
# ✓ Remplir tous les champs
# ✓ Ajouter des captures d'écran
# ✓ Rédiger la description
# ✓ Définir le prix (gratuit)
# ✓ Remplir l'avis de contenu
```

**Checklist Play Store**:
- [ ] Icône app (512x512)
- [ ] 2+ screenshots (1080x1920)
- [ ] Description complète
- [ ] Politique de confidentialité
- [ ] Conditions d'utilisation
- [ ] Version >= 1.0.0
- [ ] Numéro de version >= 1

#### App Store (iOS)

```bash
# Générer l'archive
flutter build ios --release

# Ou utiliser Xcode
open ios/Runner.xcworkspace

# Archiver et soumettre
```

**Checklist App Store**:
- [ ] SKU unique
- [ ] Icône app (1024x1024)
- [ ] 2+ screenshots pour chaque taille d'écran
- [ ] Version 1.0
- [ ] Description complète
- [ ] Mots-clés
- [ ] Politique de confidentialité
- [ ] Support URL
- [ ] Sélectionner la catégorie: Médical

---

### 10. DNS & Domaine

- [ ] Domaine acheté
- [ ] DNS configuré
  - [ ] A record vers backend
  - [ ] CNAME vers CDN
  - [ ] MX records configure (si email)
  - [ ] SPF/DKIM/DMARC (si email)

Example:
```
api.allo-secours.com  A  12.34.56.78
cdn.allo-secours.com  CNAME  d111111abcdef8.cloudfront.net
```

---

### 11. SSL/TLS Certificate

- [ ] SSL certificate obtenu (Let's Encrypt gratuit)

```bash
# Let's Encrypt + Certbot
sudo certbot certonly --standalone -d api.allo-secours.com

# Auto-renouvellement
sudo systemctl enable certbot.timer
```

- [ ] Redirection HTTP → HTTPS configurée
- [ ] HSTS header activé

---

### 12. Analytics & Monitoring

- [ ] Google Analytics configuré
- [ ] Sentry/Appsignal configuré
- [ ] Dashboard créé

```bash
# Vérifier qu'analytics fonctionne
# Ouvrir la page et vérifier dans GA Real-time
```

---

### 13. Support & Communication

- [ ] Email support configuré
- [ ] FAQ préparé
- [ ] Support documentation prêt
- [ ] Changelog préparé

---

### 14. Lancements Stratégiques

#### Beta Phase (1-2 semaines)

- [ ] Déployer sur version bêta
- [ ] Inviter 100-500 testeurs bêta
- [ ] Recueillir le feedback
- [ ] Fixer les bugs critiques
- [ ] Version bêta du navigateur Play Store: `App > Release > Internal testing / Beta`

#### Staged Rollout (1-2 semaines)

- [ ] Déployer pour 10% des utilisateurs
- [ ] Monitorer les crashs
- [ ] Augmenter à 50% après 1 semaine
- [ ] Augmenter à 100% après 1 semaine supplémentaire

---

### 15. Post-Launch

- [ ] Monitorer les crashs (Sentry)
- [ ] Vérifier les metrics (Analytics)
- [ ] Lire les avis utilisateurs
- [ ] Corriger les bugs critiques immédiatement
- [ ] Publier des mises à jour hebdomadaires

---

## 📋 Checklist Finale (24h avant)

```bash
# ==========================================
# Dernier jour avant le lancement
# ==========================================

# 1. Test complet
npm test
flutter test

# 2. Vérifier la build finale
flutter build apk --release
flutter build ios --release
ls -la build/app/outputs/

# 3. Tester en production staging
curl https://staging-api.allo-secours.com/health

# 4. Vérifier les variables env
echo $NODE_ENV  # production
echo $MONGODB_URI  # production DB

# 5. Backup de la BD
mongodump --uri "mongodb+srv://..." --out ./backup

# 6. Vérifier que HTTPS fonctionne
curl -v https://api.allo-secours.com/health

# 7. Tester le frontend une dernière fois
flutter run --release

# 8. Vérifier les logs
tail -100 backend.log

# 9. Notification au team
echo "✓ Toutes les vérifications passées!"
```

---

## 🚨 Points Critiques à Ne Pas Oublier

1. ⚠️ **Secrets**: Jamais en git, seulement via environment variables
2. ⚠️ **HTTPS**: Toujours activé en production
3. ⚠️ **Backup**: Avant chaque déploiement
4. ⚠️ **Versioning**: Incrémenter avant chaque release
5. ⚠️ **Tests**: Test une dernière fois avant de pousser
6. ⚠️ **Monitoring**: Avoir des alertes configurées
7. ⚠️ **Rollback**: Plan B au cas où ça casse
8. ⚠️ **Documentation**: À jour pour support

---

## 🔄 Rollback Plan

Si quelque chose casse en production:

```bash
# 1. Immédiatement: revert the release
git revert <commit-hash>
git push

# 2. Redéployer la version stable
npm run deploy:stable

# 3. Analyser les logs
docker logs allo-secours-backend > analysis.log

# 4. Corriger et retester
npm run test
npm run lint

# 5. Redéployer avec caution (staged rollout)
```

---

✅ **Status**: Prêt pour production après validation complète

🚀 **Bon déploiement!**
