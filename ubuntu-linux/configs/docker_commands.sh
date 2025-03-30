# Docker Start and Stop Commands
alias dockerstop="sudo systemctl stop docker.service docker.socket"
alias dockerstart="sudo systemctl start docker.service"
docker() {
    sudo /usr/bin/docker "$@"
}