# ==========================================
# Script de Démarrage Allo Secours (Windows)
# ==========================================
# Ce script configure et démarre le projet entièrement
# Usage: .\START.ps1

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Allo Secours - Startup Script       ║" -ForegroundColor Cyan
Write-Host "║  Windows PowerShell Version          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Configuration
$BACKEND_DIR = "backend"
$FRONTEND_DIR = "."

# Fonction pour vérifier les commandes
function Test-Command {
    param($Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Vérifier les prérequis
function Check-Requirements {
    Write-Host "Vérification des prérequis..." -ForegroundColor Blue
    
    # Node.js
    if (Test-Command node) {
        $version = node -v
        Write-Host "✓ Node.js trouvé: $version" -ForegroundColor Green
    }
    else {
        Write-Host "✗ Node.js n'est pas installé" -ForegroundColor Red
        Write-Host "Téléchargez: https://nodejs.org" -ForegroundColor Red
        exit 1
    }
    
    # npm
    if (Test-Command npm) {
        $version = npm -v
        Write-Host "✓ npm trouvé: $version" -ForegroundColor Green
    }
    else {
        Write-Host "✗ npm n'est pas installé" -ForegroundColor Red
        exit 1
    }
    
    # Flutter
    if (Test-Command flutter) {
        Write-Host "✓ Flutter trouvé" -ForegroundColor Green
    }
    else {
        Write-Host "✗ Flutter n'est pas installé" -ForegroundColor Red
        Write-Host "Téléchargez: https://flutter.dev/docs/get-started/install" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
}

# Configurer et démarrer MongoDB
function Setup-MongoDB {
    Write-Host "Configuration de MongoDB..." -ForegroundColor Cyan
    
    if (Test-Command docker) {
        Write-Host "ℹ️  Docker trouvé, lancement du container MongoDB" -ForegroundColor Blue
        
        $container = docker ps -a --format "{{.Names}}" | Where-Object { $_ -eq "allo-secours-mongo" }
        
        if ($container) {
            Write-Host "✓ Container MongoDB existe déjà" -ForegroundColor Green
            docker start allo-secours-mongo | Out-Null
        }
        else {
            Write-Host "ℹ️  Création du container MongoDB..." -ForegroundColor Blue
            docker run -d -p 27017:27017 --name allo-secours-mongo mongo:latest | Out-Null
        }
        
        Start-Sleep -Seconds 2
        Write-Host "✓ MongoDB lancé sur port 27017" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️  Docker n'est pas installé" -ForegroundColor Yellow
        Write-Host "⚠️  MongoDB doit être lancé manuellement:" -ForegroundColor Yellow
        Write-Host "  - Avec Docker: docker run -d -p 27017:27017 mongo:latest" -ForegroundColor Yellow
        Write-Host "  - Ou localement: mongod" -ForegroundColor Yellow
        Read-Host "Appuyez sur Entrée quand MongoDB est prêt"
    }
    
    Write-Host ""
}

# Configurer et démarrer le Backend
function Setup-Backend {
    Write-Host "Configuration du Backend..." -ForegroundColor Cyan
    
    Push-Location $BACKEND_DIR
    
    if (-not (Test-Path "node_modules")) {
        Write-Host "ℹ️  Installation des dépendances..." -ForegroundColor Blue
        npm install
    }
    else {
        Write-Host "✓ Dépendances déjà installées" -ForegroundColor Green
    }
    
    if (-not (Test-Path ".env")) {
        Write-Host "ℹ️  Création du fichier .env" -ForegroundColor Blue
        Copy-Item .env.example .env
        Write-Host "✓ .env créé" -ForegroundColor Green
    }
    
    Write-Host "ℹ️  Remplissage de la base de données..." -ForegroundColor Blue
    npm run seed
    
    Write-Host ""
    Write-Host "Lancement du serveur Backend..." -ForegroundColor Cyan
    Start-Process npm -ArgumentList "run dev"
    
    Start-Sleep -Seconds 2
    Write-Host "✓ Backend lancé sur http://localhost:3000" -ForegroundColor Green
    
    Pop-Location
    Write-Host ""
}

# Configurer Frontend
function Setup-Frontend {
    Write-Host "Configuration du Frontend..." -ForegroundColor Cyan
    
    if (-not (Test-Path "build")) {
        Write-Host "ℹ️  Récupération des dépendances Flutter..." -ForegroundColor Blue
        flutter pub get
    }
    else {
        Write-Host "✓ Dépendances déjà en place" -ForegroundColor Green
    }
    
    Write-Host "ℹ️  Configuration Flutter..." -ForegroundColor Blue
    flutter config --enable-web | Out-Null
    
    Write-Host ""
    Write-Host "Pour lancer l'app Flutter:" -ForegroundColor Cyan
    Write-Host "1. Ouvrir un nouveau terminal"
    Write-Host "2. Exécuter: flutter devices (pour voir les appareils)"
    Write-Host "3. Exécuter: flutter run"
    Write-Host ""
}

# Afficher les URLs
function Show-URLs {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║       Services Disponibles            ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Backend API" -ForegroundColor Green -NoNewline
    Write-Host ""
    Write-Host "  Base URL: http://localhost:3000"
    Write-Host "  API: http://localhost:3000/api/v1"
    Write-Host "  Health Check: http://localhost:3000/health"
    Write-Host ""
    
    Write-Host "MongoDB" -ForegroundColor Green -NoNewline
    Write-Host ""
    Write-Host "  Connection: mongodb://localhost:27017/allo-secours"
    Write-Host "  Utilisateur de test:"
    Write-Host "    Email: giovani@example.com"
    Write-Host "    Mot de passe: password123"
    Write-Host ""
    
    Write-Host "Services Disponibles" -ForegroundColor Green -NoNewline
    Write-Host ""
    Write-Host "  1. Hôpital Central Paris"
    Write-Host "  2. Pharmacie Santé Plus"
    Write-Host "  3. Dr. Ahmed Cardiologue"
    Write-Host "  4. SAMU Urgences"
    Write-Host "  5. Imagerie Médicale Ouest"
    Write-Host ""
}

# Menu Principal
function Main {
    Check-Requirements
    
    Write-Host "Que voulez-vous faire?" -ForegroundColor Cyan
    Write-Host "1. Démarrer complètement (Backend + Frontend)"
    Write-Host "2. Démarrer seulement le Backend"
    Write-Host "3. Démarrer seulement le Frontend"
    Write-Host "4. Voir les URLs des services"
    Write-Host "5. Quitter"
    Write-Host ""
    
    $choice = Read-Host "Choisir (1-5)"
    
    switch ($choice) {
        "1" {
            Setup-MongoDB
            Setup-Backend
            Setup-Frontend
            Show-URLs
        }
        "2" {
            Setup-MongoDB
            Setup-Backend
            Show-URLs
        }
        "3" {
            Setup-Frontend
            Show-URLs
        }
        "4" {
            Show-URLs
        }
        "5" {
            Write-Host "Au revoir!" -ForegroundColor Green
            exit 0
        }
        default {
            Write-Host "Option invalide" -ForegroundColor Red
            exit 1
        }
    }
}

# Exécuter le menu principal
Main
