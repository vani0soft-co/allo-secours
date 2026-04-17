#!/bin/bash

# ==========================================
# Script de Démarrage Allo Secours
# ==========================================
# Ce script configure et démarre le projet entièrement

echo "╔════════════════════════════════════════╗"
echo "║  Allo Secours - Startup Script       ║"
echo "║  Démarrage Backend + Frontend        ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BACKEND_DIR="backend"
FRONTEND_DIR="."

# Fonction pour afficher les messages
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

error() {
    echo -e "${RED}✗ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Vérifier les prérequis
check_requirements() {
    echo "Vérification des prérequis..."
    
    # Node.js
    if ! command -v node &> /dev/null; then
        error "Node.js n'est pas installé"
        echo "Téléchargez: https://nodejs.org"
        exit 1
    fi
    success "Node.js trouvé: $(node -v)"
    
    # npm
    if ! command -v npm &> /dev/null; then
        error "npm n'est pas installé"
        exit 1
    fi
    success "npm trouvé: $(npm -v)"
    
    # Flutter
    if ! command -v flutter &> /dev/null; then
        error "Flutter n'est pas installé"
        echo "Téléchargez: https://flutter.dev/docs/get-started/install"
        exit 1
    fi
    success "Flutter trouvé: $(flutter --version | head -n 1)"
    
    echo ""
}

# Configurer et démarrer MongoDB
setup_mongodb() {
    echo "Configuration de MongoDB..."
    
    if command -v docker &> /dev/null; then
        info "Docker trouvé, lancement du container MongoDB"
        
        # Vérifier si le container existe
        if docker ps -a --format '{{.Names}}' | grep -q '^allo-secours-mongo$'; then
            success "Container MongoDB existe déjà"
            docker start allo-secours-mongo
        else
            info "Création du container MongoDB..."
            docker run -d -p 27017:27017 --name allo-secours-mongo mongo:latest
        fi
        
        sleep 2
        success "MongoDB lancé sur port 27017"
    else
        warning "Docker n'est pas installé"
        warning "MongoDB doit être lancé manuellement:"
        warning "  - Avec Docker: docker run -d -p 27017:27017 mongo:latest"
        warning "  - Ou localement: mongod"
        read -p "Appuyez sur Entrée quand MongoDB est prêt..."
    fi
    
    echo ""
}

# Configurer et démarrer le Backend
setup_backend() {
    echo "Configuration du Backend..."
    
    cd "$BACKEND_DIR"
    
    if [ ! -d "node_modules" ]; then
        info "Installation des dépendances..."
        npm install
    else
        success "Dépendances déjà installées"
    fi
    
    if [ ! -f ".env" ]; then
        info "Création du fichier .env"
        cp .env.example .env
        success ".env créé (à personnaliser si nécessaire)"
    fi
    
    info "Remplissage de la base de données..."
    npm run seed
    
    echo ""
    echo "Lancement du serveur Backend..."
    npm run dev &
    BACKEND_PID=$!
    
    sleep 3
    success "Backend lancé (PID: $BACKEND_PID)"
    
    cd ..
    echo ""
}

# Configurer et démarrer le Frontend
setup_frontend() {
    echo "Configuration du Frontend..."
    
    if [ ! -d "build" ]; then
        info "Récupération des dépendances Flutter..."
        flutter pub get
    else
        success "Dépendances déjà en place"
    fi
    
    info "Lancement de la configuration Flutter..."
    flutter config --enable-web >/dev/null 2>&1
    
    echo ""
    echo "Lancement du Frontend..."
    echo "Sélectionnez votre appareil/émulateur:"
    flutter devices
    echo ""
    
    info "App Flutter: exécutez 'flutter run' dans un autre terminal"
    
    echo ""
}

# Afficher les URLs
show_urls() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║       Services Disponibles            ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo -e "${GREEN}Backend API${NC}"
    echo "  Base URL: http://localhost:3000"
    echo "  API: http://localhost:3000/api/v1"
    echo "  Health Check: http://localhost:3000/health"
    echo ""
    echo -e "${GREEN}MongoDB${NC}"
    echo "  MongoDB: mongodb://localhost:27017/allo-secours"
    echo "  Utilisateur de test:"
    echo "    Email: giovani@example.com"
    echo "    Mot de passe: password123"
    echo ""
    echo -e "${GREEN}Services Disponibles${NC}"
    echo "  1. Hôpital Central Paris"
    echo "  2. Pharmacie Santé Plus"
    echo "  3. Dr. Ahmed Cardiologue"
    echo "  4. SAMU Urgences"
    echo "  5. Imagerie Médicale Ouest"
    echo ""
}

# Menu Principal
main() {
    check_requirements
    
    echo "Que voulez-vous faire?"
    echo "1. Démarrer complètement (Backend + Frontend)"
    echo "2. Démarrer seulement le Backend"
    echo "3. Démarrer seulement le Frontend"
    echo "4. Voir les URLs des services"
    echo "5. Arrêter tout"
    echo ""
    
    read -p "Choisir (1-5): " choice
    
    case $choice in
        1)
            setup_mongodb
            setup_backend
            setup_frontend
            show_urls
            ;;
        2)
            setup_mongodb
            setup_backend
            show_urls
            ;;
        3)
            setup_frontend
            show_urls
            ;;
        4)
            show_urls
            ;;
        5)
            error "Arrêt en cours..."
            # Arrêter le backend
            if [ ! -z "$BACKEND_PID" ]; then
                kill $BACKEND_PID
                success "Backend arrêté"
            fi
            # Arrêter MongoDB si lancé via Docker
            docker stop allo-secours-mongo 2>/dev/null
            success "MongoDB arrêté"
            success "Fermeture terminée"
            exit 0
            ;;
        *)
            error "Option invalide"
            exit 1
            ;;
    esac
}

# Run if script is executed directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main
fi
