#!/bin/sh

TRAEFIK_CONTAINER_NAME='devcontainers-traefik'

# DevContainers CLI does not set any specific environment variables; we, therefore, have to exclude the environments where we don't want to start Traefik
# So far, the only such environment is GitHub Codespaces
# Codespaces set `CODESPACES=true` and `CODESPACE_NAME` to the name of the codespace (there are also GitHub-specific variables like `GITHUB_TOKEN` or `GITHUB_USER`)
if [ "${CODESPACES}" != 'true' ] && [ -z "${CODESPACE_NAME}" ]; then
    if hash docker 2>/dev/null; then
        if [ -z "$(docker ps -q -f name="${TRAEFIK_CONTAINER_NAME}")" ]; then
            docker container rm "${TRAEFIK_CONTAINER_NAME}"
            docker run -d --name "${TRAEFIK_CONTAINER_NAME}" --restart always -v /var/run/docker.sock:/var/run/docker.sock -p 90:80 -p 8088:8080 traefik:mimolette \
                --api.insecure=true --providers.docker=true --providers.docker.exposedByDefault=false --entrypoints.http.address=:80
            echo "(*) Started Traefik container"
        else
            echo "(*) Traefik container is already running"
        fi
    else
        echo "(!) Unable to find Docker; not starting Traefik"
    fi
else
    echo "(!) Running in GitHub Codespaces; not starting Traefik"
fi
