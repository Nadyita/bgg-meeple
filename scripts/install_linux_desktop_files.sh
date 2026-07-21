#!/bin/sh
# Install the BGG Meeple .desktop entry and icons into the user's home directory.
# This makes the window icon appear correctly under Wayland/X11 compositors.

set -eu

BUNDLE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APPLICATION_ID="com.bggmeeple.bgg_meeple"

LOCAL_APPS="${HOME}/.local/share/applications"
LOCAL_ICONS="${HOME}/.local/share/icons/hicolor"
SCALABLE_DIR="${LOCAL_ICONS}/scalable/apps"

mkdir -p "${LOCAL_APPS}"
mkdir -p "${SCALABLE_DIR}"

echo "Installing ${APPLICATION_ID}.desktop..."
sed "s|Exec=bgg_meeple|Exec=${BUNDLE_DIR}/bgg_meeple|" \
    "${BUNDLE_DIR}/data/applications/${APPLICATION_ID}.desktop" \
    > "${LOCAL_APPS}/${APPLICATION_ID}.desktop"
chmod +x "${LOCAL_APPS}/${APPLICATION_ID}.desktop"

echo "Installing scalable icon..."
cp "${BUNDLE_DIR}/data/${APPLICATION_ID}.svg" "${SCALABLE_DIR}/${APPLICATION_ID}.svg"

echo "Installing sized icons..."
for size_dir in "${BUNDLE_DIR}/data/icons/"*; do
    if [ -d "${size_dir}" ]; then
        size="$(basename "${size_dir}")"
        target_dir="${LOCAL_ICONS}/${size}/apps"
        mkdir -p "${target_dir}"
        cp "${size_dir}/apps/${APPLICATION_ID}.png" "${target_dir}/${APPLICATION_ID}.png"
    fi
done

echo "Updating icon caches..."
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t "${LOCAL_ICONS}" || true
fi

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "${LOCAL_APPS}" || true
fi

echo "Done. You may need to restart the app or log out and back in."
