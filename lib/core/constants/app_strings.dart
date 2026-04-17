class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'LogiTrack';
  static const String appTagline = 'Location & Livraison simplifiées';

  // Auth
  static const String login = 'Connexion';
  static const String register = "S'inscrire";
  static const String logout = 'Déconnexion';
  static const String email = 'Adresse email';
  static const String password = 'Mot de passe';
  static const String confirmPassword = 'Confirmer le mot de passe';
  static const String fullName = 'Nom complet';
  static const String phoneNumber = 'Numéro de téléphone';
  static const String forgotPassword = 'Mot de passe oublié ?';
  static const String resetPassword = 'Réinitialiser le mot de passe';
  static const String noAccount = "Pas encore de compte ?";
  static const String alreadyAccount = 'Déjà un compte ?';
  static const String loginWithGoogle = 'Continuer avec Google';
  static const String createAccount = 'Créer un compte';
  static const String welcomeBack = 'Bon retour !';
  static const String welcomeNew = 'Créer votre compte';

  // Navigation client
  static const String home = 'Accueil';
  static const String cars = 'Voitures';
  static const String parcels = 'Colis';
  static const String myBookings = 'Réservations';
  static const String profile = 'Profil';
  static const String notifications = 'Notifications';

  // Navigation admin
  static const String dashboard = 'Tableau de bord';
  static const String manageCars = 'Voitures';
  static const String manageReservations = 'Réservations';
  static const String manageParcels = 'Colis';
  static const String manageClients = 'Clients';

  // Cars
  static const String availableCars = 'Voitures disponibles';
  static const String carDetail = 'Détail du véhicule';
  static const String bookNow = 'Réserver maintenant';
  static const String addCar = 'Ajouter une voiture';
  static const String editCar = 'Modifier la voiture';
  static const String deleteCar = 'Supprimer la voiture';
  static const String carBrand = 'Marque';
  static const String carModel = 'Modèle';
  static const String carYear = 'Année';
  static const String carSeats = 'Nombre de places';
  static const String transmission = 'Transmission';
  static const String automatic = 'Automatique';
  static const String manual = 'Manuelle';
  static const String pricePerDay = 'Prix par jour';
  static const String deposit = 'Caution';
  static const String available = 'Disponible';
  static const String unavailable = 'Indisponible';
  static const String selectDates = 'Sélectionner les dates';
  static const String startDate = 'Date de début';
  static const String endDate = 'Date de fin';
  static const String totalDays = 'Nombre de jours';
  static const String totalCost = 'Coût total';
  static const String confirmBooking = 'Confirmer la réservation';

  // Parcels
  static const String sendParcel = 'Envoyer un colis';
  static const String trackParcel = 'Suivre un colis';
  static const String myParcels = 'Mes colis';
  static const String createParcel = 'Créer un envoi';
  static const String senderInfo = "Informations de l'expéditeur";
  static const String recipientInfo = 'Informations du destinataire';
  static const String parcelInfo = 'Informations du colis';
  static const String senderName = "Nom de l'expéditeur";
  static const String senderAddress = "Adresse de l'expéditeur";
  static const String recipientName = 'Nom du destinataire';
  static const String recipientPhone = 'Téléphone du destinataire';
  static const String recipientAddress = 'Adresse du destinataire';
  static const String parcelWeight = 'Poids (kg)';
  static const String parcelDimensions = 'Dimensions (cm)';
  static const String parcelType = 'Type de colis';
  static const String standard = 'Standard';
  static const String express = 'Express';
  static const String fragile = 'Fragile';
  static const String trackingCode = 'Code de suivi';
  static const String estimatedCost = 'Coût estimé';
  static const String confirmSend = "Confirmer l'envoi";

  // Statuts
  static const String statusPending = 'En attente';
  static const String statusConfirmed = 'Confirmé';
  static const String statusActive = 'En cours';
  static const String statusCompleted = 'Terminé';
  static const String statusCancelled = 'Annulé';
  static const String statusPickedUp = 'Pris en charge';
  static const String statusInTransit = 'En transit';
  static const String statusDelivered = 'Livré';

  // Boutons
  static const String confirm = 'Confirmer';
  static const String cancel = 'Annuler';
  static const String save = 'Enregistrer';
  static const String edit = 'Modifier';
  static const String delete = 'Supprimer';
  static const String back = 'Retour';
  static const String next = 'Suivant';
  static const String previous = 'Précédent';
  static const String search = 'Rechercher';
  static const String filter = 'Filtrer';
  static const String seeAll = 'Voir tout';
  static const String retry = 'Réessayer';
  static const String close = 'Fermer';

  // Messages
  static const String loading = 'Chargement...';
  static const String noData = 'Aucune donnée disponible';
  static const String noCars = 'Aucune voiture disponible';
  static const String noParcels = 'Aucun colis trouvé';
  static const String noReservations = 'Aucune réservation';
  static const String noNotifications = 'Aucune notification';
  static const String errorOccurred = 'Une erreur est survenue';
  static const String tryAgain = 'Veuillez réessayer';
  static const String successBooking = 'Réservation effectuée avec succès';
  static const String successParcel = 'Colis créé avec succès';
  static const String successUpdate = 'Mise à jour effectuée';
  static const String successDelete = 'Suppression effectuée';
  static const String confirmDelete = 'Confirmer la suppression';
  static const String deleteWarning =
      'Cette action est irréversible. Voulez-vous continuer ?';

  // Validation
  static const String required = 'Ce champ est obligatoire';
  static const String invalidEmail = 'Adresse email invalide';
  static const String weakPassword =
      'Le mot de passe doit contenir au moins 6 caractères';
  static const String passwordMismatch =
      'Les mots de passe ne correspondent pas';
  static const String invalidPhone = 'Numéro de téléphone invalide';

  // Statuts labels
  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPending;
      case 'confirmed':
        return statusConfirmed;
      case 'active':
        return statusActive;
      case 'completed':
        return statusCompleted;
      case 'cancelled':
        return statusCancelled;
      case 'picked_up':
        return statusPickedUp;
      case 'in_transit':
        return statusInTransit;
      case 'delivered':
        return statusDelivered;
      default:
        return status;
    }
  }
}