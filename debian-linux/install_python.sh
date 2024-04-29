set -e

# Install pyenv
curl https://pyenv.run | bash

# Install build dependencies
sudo apt update; sudo apt install -y build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# Install the LTS Python
pyenv install 3.12
pyenv global 3.12

# Install PIPX
python -m pip install pipx
python3 -m pipx ensurepath

# Install Poetry
pipx install poetry
pipx ensurepath



