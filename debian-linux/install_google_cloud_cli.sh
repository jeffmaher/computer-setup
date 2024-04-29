set -e

# Install dependencies
sudo apt-get install apt-transport-https ca-certificates gnupg curl sudo -y

# Install Google Cloud public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

# Add package source to apt
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Install the CLI
sudo apt-get update && sudo apt-get install google-cloud-cli -y

# Login
gcloud init