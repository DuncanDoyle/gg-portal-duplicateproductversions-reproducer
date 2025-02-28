#!/bin/bash

export K8S_GATEWAY_API_VERSION=v1.1.0

export GLOO_GATEWAY_VERSION="1.18.4"
# export GLOO_GATEWAY_VERSION="1.17.5"

export DEV_VERSION=false
export GLOO_GATEWAY_HELM_VALUES_FILE="gloo-gateway-helm-values.yaml"

export GATEWAY_NAMESPACE=gloo-system

# export GATEWAY_HOST=api.example.com
export PORTAL_HOST=developer.example.com
export PARTNER_PORTAL_HOST=developer.partner.example.com
export KEYCLOAK_HOST=keycloak.example.com
export KC_ADMIN_PASS=admin