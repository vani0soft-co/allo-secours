# ==========================================
# Dockerfile - Backend Allo Secours
# ==========================================

# Stage 1: Build
FROM node:18-alpine AS builder

WORKDIR /app

# Copier les fichiers de package
COPY package*.json ./

# Installer les dépendances
RUN npm ci --only=production

# Stage 2: Runtime
FROM node:18-alpine

WORKDIR /app

# Variables d'environnement par défaut
ENV NODE_ENV=production
ENV PORT=3000

# Copier les dépendances depuis le builder
COPY --from=builder /app/node_modules /app/node_modules

# Copier le code source
COPY . .

# Expose le port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Commande de démarrage
CMD ["npm", "start"]
