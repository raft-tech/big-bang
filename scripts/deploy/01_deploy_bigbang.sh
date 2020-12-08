#!/bin/bash

set -e

# Deploy flux and wait for it to be ready
echo "Installing Flux"
kubectl apply -f https://repo1.dsop.io/platform-one/big-bang/apps/sandbox/fluxv2/-/raw/master/flux-system.yaml
flux check

# Deploy BigBang
helm upgrade -i bigbang chart -n bigbang --create-namespace --set registryCredentials.username='robot$bigbang' --set registryCredentials.password=${REGISTRY1_PASSWORD} --set addons.argocd.enabled=true --set addons.authservice.enabled=true

# Apply secrets kustomization pointing to current branch
echo "Deploying secrets from branch ${CI_COMMIT_REF_NAME}"
cat examples/complete/envs/dev/source-secrets.yaml | sed 's|master|'$CI_COMMIT_REF_NAME'|g' | kubectl apply -f -