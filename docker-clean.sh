#!/bin/bash
set -euo pipefail

echo "=== Docker Cleanup Preview ==="
echo

# Show what will be affected
running=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
stopped=$(docker ps -aq 2>/dev/null | wc -l | tr -d ' ')
images=$(docker images -q 2>/dev/null | wc -l | tr -d ' ')
volumes=$(docker volume ls -q 2>/dev/null | wc -l | tr -d ' ')
networks=$(docker network ls -q 2>/dev/null | wc -l | tr -d ' ')

echo "This will:"
echo "  - Stop $running running container(s)"
echo "  - Remove $stopped total container(s)"
echo "  - Remove $images image(s)"
echo "  - Remove $volumes volume(s)"
echo "  - Remove unused networks (currently $networks total)"
echo

# Show running containers by name if any
if [ "$running" -gt 0 ]; then
    echo "Running containers that will be stopped:"
    docker ps --format "  - {{.Names}} ({{.Image}})"
    echo
fi

# Confirmation
read -p "Proceed with cleanup? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo
echo "=== Cleaning ==="

echo "Stopping all running containers..."
docker stop $(docker ps -q) 2>/dev/null || echo "No running containers"

echo "Removing stopped containers..."
docker container prune -f

echo "Removing unused images..."
docker image prune -af

echo "Removing unused volumes..."
docker volume prune -f

echo "Removing unused networks..."
docker network prune -f

echo
echo "=== Done ==="
docker system df
