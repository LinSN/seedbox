#!/bin/bash

# Définition des couleurs pour une meilleure lisibilité
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERREUR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCÈS]${NC} $1"
}

# Vérification que le script est exécuté en root
if [ "$EUID" -ne 0 ]; then 
    error "Ce script doit être exécuté en tant que root"
    exit 1
fi

# Installation des dépendances de base
log "Installation des dépendances de base..."
apt-get update
apt-get install -y \
    curl \
    git \
    zsh \
    wget \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Installation de Docker
log "Installation de Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# Installation de Docker Compose V2
log "Installation de Docker Compose..."
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Création des dossiers nécessaires
log "Création des dossiers..."
mkdir -p /data/{downloads,config/{traefik,Plex,sonarr,radarr,bazarr,lidarr,transmission,tautulli,prowlarr,portainer}}

# Configuration des permissions
log "Configuration des permissions..."
PUID=${PUID:-1000}
PGID=${PGID:-1000}

chown -R $PUID:$PGID /data
chmod -R 755 /data

# Installation de docker-volume-local-persist
log "Installation de docker-volume-local-persist..."
curl -fsSL https://raw.githubusercontent.com/MatchbookLab/local-persist/master/scripts/install.sh | bash

# Création du réseau Docker
log "Création du réseau Docker..."
docker network create traefik-network 2>/dev/null || true

# Installation de Oh My Zsh
log "Installation de Oh My Zsh..."
# Installation pour l'utilisateur root
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Installation pour l'utilisateur normal (en supposant que $SUDO_USER existe)
if [ ! -z "$SUDO_USER" ]; then
    su - $SUDO_USER -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
    
    # Installation des plugins populaires pour Oh My Zsh
    log "Installation des plugins pour Oh My Zsh..."
    ZSH_CUSTOM="/home/$SUDO_USER/.oh-my-zsh/custom"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
    
    # Configuration de .zshrc
    sed -i 's/plugins=(git)/plugins=(git docker docker-compose zsh-autosuggestions zsh-syntax-highlighting)/' /home/$SUDO_USER/.zshrc
    
    # Changement du shell par défaut pour l'utilisateur
    chsh -s $(which zsh) $SUDO_USER
fi

# Vérification/Création du fichier .env
if [[ ! -f .env ]]; then
    log "Création du fichier .env..."
    cat > .env << EOL
# Paramètres généraux
TZ=Europe/Paris
PUID=1000
PGID=1000

# Traefik
TRAEFIK_DOMAIN=votre-domaine.com
ACME_MAIL=votre-email@example.com

# Google OAuth
PROVIDERS_GOOGLE_CLIENT_ID=votre-client-id
PROVIDERS_GOOGLE_CLIENT_SECRET=votre-client-secret
SECRET=un-secret-aleatoire

# Portainer
PORTAINER_ADMIN_PASSWORD=votre-mot-de-passe
EOL
    success "Fichier .env créé. Veuillez le modifier avec vos paramètres."
fi

# Vérification finale
log "Vérification de l'installation..."
if command -v docker >/dev/null 2>&1; then
    success "Docker est installé correctement"
    docker --version
    docker compose version
else
    error "Problème avec l'installation de Docker"
    exit 1
fi

# Instructions finales
success "Installation terminée!"
echo -e "\nÉtapes suivantes :"
echo "1. Modifiez le fichier .env avec vos paramètres"
echo "2. Lancez les conteneurs avec 'docker compose up -d'"
echo "3. Vérifiez les logs avec 'docker compose logs -f'"
echo "4. Déconnectez-vous et reconnectez-vous pour utiliser Oh My Zsh"

exit 0