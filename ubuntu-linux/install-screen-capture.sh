set -e

# --- vokoscreenNG ---
flatpak install flathub com.github.vkohaupt.vokoscreenNG -y


# --- Kooha ---
# Kooha seems to produce bad videos for anything longer than a minute.
# For example, it'll capture all the audio, but the video will be stuck at an earlier frame throughout
# flatpak install flathub kooha -y