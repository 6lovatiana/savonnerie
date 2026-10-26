#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BUILD_FILE="$PROJECT_ROOT/build.xml"

if [[ -n "${WILDFLY_HOME:-}" ]]; then
    WILDFLY_HOME="$WILDFLY_HOME"
elif [[ -d /opt/wildfly ]]; then
    WILDFLY_HOME="/opt/wildfly"
elif [[ -d "$HOME/wildfly-10.1.0.Final" ]]; then
    WILDFLY_HOME="$HOME/wildfly-10.1.0.Final"
else
    WILDFLY_HOME="/opt/wildfly"
fi
ANT_COMMAND="${ANT_COMMAND:-ant}"
JAVA_HOME_OVERRIDE="${JAVA_HOME_OVERRIDE:-${JAVA_HOME:-}}"
HTTP_PORT="${HTTP_PORT:-8088}"

usage() {
    cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --wildfly-home PATH   Répertoire d'installation de WildFly
  --ant-command PATH    Commande ou chemin vers Ant
  --java-home PATH      Répertoire d'un JDK 8
  --http-port PORT      Port HTTP de WildFly (défaut: 8088)
  -h, --help            Afficher cette aide

Variables équivalentes : WILDFLY_HOME, ANT_COMMAND, JAVA_HOME_OVERRIDE,
HTTP_PORT.
EOF
}

error() {
    printf 'Erreur : %s\n' "$*" >&2
    exit 1
}

while (($# > 0)); do
    case "$1" in
        --wildfly-home)
            (($# >= 2)) || error "Valeur manquante pour --wildfly-home."
            WILDFLY_HOME="$2"
            shift 2
            ;;
        --ant-command)
            (($# >= 2)) || error "Valeur manquante pour --ant-command."
            ANT_COMMAND="$2"
            shift 2
            ;;
        --java-home)
            (($# >= 2)) || error "Valeur manquante pour --java-home."
            JAVA_HOME_OVERRIDE="$2"
            shift 2
            ;;
        --http-port)
            (($# >= 2)) || error "Valeur manquante pour --http-port."
            HTTP_PORT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            error "Option inconnue : $1"
            ;;
    esac
done

[[ -f "$BUILD_FILE" ]] || error "Le fichier de compilation est introuvable : $BUILD_FILE"

WILDFLY_HOME_INPUT="$WILDFLY_HOME"
WILDFLY_HOME="$(cd -- "$WILDFLY_HOME_INPUT" 2>/dev/null && pwd -P)" ||
    error "WildFly est introuvable : '$WILDFLY_HOME_INPUT'. Indiquez --wildfly-home ou WILDFLY_HOME."

DEPLOY_DIRECTORY="$WILDFLY_HOME/standalone/deployments"
STANDALONE="$WILDFLY_HOME/bin/standalone.sh"
LIBRARIES="$PROJECT_ROOT/build-file/lib"

[[ -f "$STANDALONE" ]] ||
    error "WildFly est introuvable dans '$WILDFLY_HOME'. Indiquez --wildfly-home ou WILDFLY_HOME."
[[ -d "$LIBRARIES" ]] && compgen -G "$LIBRARIES/*.jar" >/dev/null ||
    error "Les bibliothèques Ant sont absentes de '$LIBRARIES'."

RUNNING_WILDFLY="$(pgrep -f -- "-Djboss.home.dir=$WILDFLY_HOME" || true)"
if [[ -n "$RUNNING_WILDFLY" ]]; then
    error "WildFly est déjà lancé (PID(s) : ${RUNNING_WILDFLY//$'\n'/, }). Arrêtez ces processus avant de relancer le script."
fi

if [[ "$ANT_COMMAND" == */* ]]; then
    [[ -x "$ANT_COMMAND" ]] || error "Ant est introuvable ou non exécutable : '$ANT_COMMAND'."
else
    command -v "$ANT_COMMAND" >/dev/null 2>&1 ||
        error "Apache Ant est introuvable ('$ANT_COMMAND'). Installez Ant ou indiquez --ant-command."
fi

if [[ -n "$JAVA_HOME_OVERRIDE" ]]; then
    JAVA_HOME_OVERRIDE="$(cd -- "$JAVA_HOME_OVERRIDE" 2>/dev/null && pwd -P)" ||
        error "Le répertoire Java est introuvable : '$JAVA_HOME_OVERRIDE'."
    [[ -x "$JAVA_HOME_OVERRIDE/bin/javac" ]] ||
        error "Aucun compilateur javac n'a été trouvé dans '$JAVA_HOME_OVERRIDE'."
    export JAVA_HOME="$JAVA_HOME_OVERRIDE"
    export PATH="$JAVA_HOME/bin:$PATH"
fi

command -v javac >/dev/null 2>&1 ||
    error "Le compilateur javac est introuvable. Définissez JAVA_HOME ou utilisez --java-home avec un JDK 8."

JAVA_VERSION="$(java -version 2>&1 || true)"
if [[ "$JAVA_VERSION" != *'version "1.8.'* ]]; then
    error "WildFly 10 requiert Java 8. Version détectée : ${JAVA_VERSION//$'\n'/ }"
fi

mkdir -p "$DEPLOY_DIRECTORY"
rm -rf -- "$DEPLOY_DIRECTORY/socobis.war"
rm -rf -- "$WILDFLY_HOME/standalone/tmp/vfs/deployment"
for status_suffix in .deployed .failed .isdeploying .pending .undeployed .dodeploy; do
    rm -f -- "$DEPLOY_DIRECTORY/socobis.war$status_suffix"
done

printf '\033[36mCompilation et déploiement de Savonnerie...\033[0m\n'
(
    cd -- "$PROJECT_ROOT"
    "$ANT_COMMAND" "-Ddeploy.dir=$DEPLOY_DIRECTORY" -f "$BUILD_FILE" deploy
)

DEPLOYMENT_MARKER="$DEPLOY_DIRECTORY/socobis.war.dodeploy"
[[ -f "$DEPLOYMENT_MARKER" ]] ||
    error "Ant n'a pas créé le marqueur de déploiement attendu : $DEPLOYMENT_MARKER"

printf '\033[36mDémarrage de WildFly. Appuyez sur Ctrl+C pour arrêter le serveur.\033[0m\n'
printf '\033[32mURL locale : http://localhost:%s/socobis\033[0m\n' "$HTTP_PORT"

cd -- "$WILDFLY_HOME/bin"
exec "$STANDALONE" -b 127.0.0.1 "-Djboss.http.port=$HTTP_PORT"
