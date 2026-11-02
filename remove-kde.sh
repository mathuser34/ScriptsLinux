
#!/bin/bash

set -e

echo "======================================"
echo "   DESINSTALADOR COMPLETO DE KDE"
echo "======================================"

if [[ $EUID -eq 0 ]]; then
    echo "No ejecutes este script como root."
    exit 1
fi

echo
echo "Este script eliminará Plasma y aplicaciones KDE."
echo "SDDM y sus configuraciones se conservarán."
echo
read -rp "¿Continuar? (escribe SI): " confirm

if [[ "$confirm" != "SI" ]]; then
    echo "Cancelado."
    exit 0
fi

echo "Eliminando paquetes KDE..."

mapfile -t packages < <(
    pacman -Qq | grep -E \
    '^(plasma|plasma6|kde-applications|kde-application|kde-utilities|kde-system|kde-graphics|kde-multimedia|kde-network|kde-pim|kde-sdk|kde-games|kde-accessibility|kde-education|kde-toys|kdevelop|dolphin|konsole|okular|gwenview|kate|kcalc|ark|spectacle|kamoso|kwallet|kio|kio-extras|kwayland|kwin|kirigami|kglobalaccel|kservice|kconfig|kcoreaddons|kfilemetadata|kimageformats|kiconthemes|knotifications|knotifyconfig|knewstuff|kparts|ktexteditor|kxmlgui|solid|sonnet|baloo|phonon-qt6|systemsettings|sddm-kcm)' \
    | grep -vx 'sddm' || true
)

if ((${#packages[@]})); then
    printf '%s\n' "${packages[@]}"
    echo
    echo "Revisa la lista antes de confirmar."
    read -rp "¿Desinstalar estos paquetes? (SI): " confirm

    if [[ "$confirm" == "SI" ]]; then
        doas pacman -Rns "${packages[@]}"
    else
        echo "Desinstalación cancelada."
        exit 0
    fi
else
    echo "No se encontraron paquetes KDE."
fi

echo
echo "Limpiando dependencias huérfanas..."

orphans=$(pacman -Qdtq || true)

if [[ -n "$orphans" ]]; then
    echo "$orphans"
    echo "No se eliminarán automáticamente."
    echo "Revísalas manualmente con: pacman -Qdt"
fi

echo
echo "Limpieza de configuraciones personales..."

rm -rf ~/.config/plasma*
rm -rf ~/.config/kwin*
rm -rf ~/.config/kdeglobals
rm -rf ~/.config/kde.org
rm -rf ~/.local/share/plasma
rm -rf ~/.local/share/kwin
rm -rf ~/.cache/plasma*

echo
echo "¡Proceso terminado!"
echo "SDDM se ha conservado."
