LOCKFILE := "package-lock.json"

update:
    git submodule update --recursive --remote
    cd packages && git checkout master && git pull

build:
    turbo build
renew:
    if [ -d {{LOCKFILE}} ]; then \
        rm {{LOCKFILE}}; \
    fi \
    && find . -name 'node_modules' -type d -prune -print -exec rm -rf '{}' \; \
    && npm i
