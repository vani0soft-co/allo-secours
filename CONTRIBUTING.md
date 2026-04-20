# Contribuer à Allo Secours

Merci de votre intérêt à contribuer ! Voici comment procéder:

## 🤝 Code de Conduite

Soyez respectueux et professionnel. Tous les contributeurs doivent respecter notre code de conduite.

## 🔍 Comment Contribuer

### 1. Fork le projet
```bash
git fork https://github.com/yourusername/allo-secours.git
```

### 2. Créer une branche
```bash
git checkout -b feature/votre-fonctionnalite
```

### 3. Faire vos modifications
- Respectez les conventions de code
- Écrivez des commits clairs et descriptifs
- Testez votre code

### 4. Tester et valider
```bash
flutter analyze
flutter test
dart format lib/
```

### 5. Pousser vos changements
```bash
git push origin feature/votre-fonctionnalite
```

### 6. Créer une Pull Request
- Décrivez clairement vos changements
- Liez les issues pertinentes
- Attendez la révision

## 📋 Types de Contributions

### Bugs
- Signaler les bugs dans la section "Issues"
- Inclure les étapes de reproduction
- Spécifier l'OS et la version Flutter

### Nouvelles Fonctionnalités
- Ouvrir une issue pour discussion
- Attendre l'approbation
- Implémenter et tester

### Documentation
- Corriger les erreurs typographiques
- Ajouter des explications
- Améliorer la clarté

### Tests
- Ajouter des tests unitaires
- Ajouter des tests d'intégration
- Augmenter la couverture

## 📝 Commits

Format des messages:
```
feat: Ajouter le support des favoris
fix: Corriger le crash sur la recherche
docs: Mettre à jour la documentation
style: Formater le code
test: Ajouter les tests pour la localisation
chore: Mettre à jour les dépendances
```

## ✅ Checklist avant le PR

- [ ] Code formaté avec `dart format`
- [ ] Pas d'erreurs: `flutter analyze`
- [ ] Tests passent: `flutter test`
- [ ] Commit messages clairs
- [ ] Documentation mise à jour
- [ ] Pas de changements non liés au PR

## 🎯 Domaines Prioritaires

1. **Performance**: Optimiser les requêtes API
2. **UX/Design**: Améliorer l'interface
3. **Tests**: Augmenter la couverture
4. **Documentation**: Améliorer le README
5. **i18n**: Support multi-langue

## ❓ Questions?

- Ouvrir une discussion
- Vous contacter sur les issues
- Envoyer un email: dev@allo-secours.com

---

Merci de contribuer! 🙏
