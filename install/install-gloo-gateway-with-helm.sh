#!/bin/sh

source ./env.sh

if [ -z "$GLOO_GATEWAY_LICENSE_KEY" ]
then
   echo "Gloo Gateway License Key not specified. Please configure the environment variable 'GLOO_EDGE_LICENSE_KEY' with your Gloo Edge License Key."
   exit 1
fi


#----------------------------------------- Deploy K8S Gateway API CRDs -----------------------------------------
printf "\nApply K8S Gateway CRDs ....\n"
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml


#----------------------------------------- Deploy Keycloak -----------------------------------------
pushd ../

# Install Keycloak
printf "\nInstall Keycloak ...\n"
# Create Keycloak namespace if it does not yet exist
kubectl create namespace keycloak --dry-run=client -o yaml | kubectl apply -f -
# Label the httpbin namespace, so the gateway will accept the HTTPRoute from that namespace.
printf "\nLabel keycloak namespace ...\n"
kubectl label namespaces keycloak --overwrite shared-gateway-access="true"

# ddoyle: Not using realm imports from configmaps for now ... might add this later to demo when it's more polished.
# ddoyle: For now will keep using the Keycloak REST API to set things up ....
# kubectl apply -f keycloak/keycloak-realms-cm.yaml

kubectl apply -f keycloak/keycloak-secrets.yaml
kubectl apply -f keycloak/keycloak-db-pv.yaml
kubectl apply -f keycloak/keycloak-postgres.yaml
printf "\nWait for Keycloak Postgres readiness ...\n"
kubectl -n keycloak rollout status deploy/postgres

kubectl apply -f keycloak/keycloak.yaml
printf "\nWait for Keycloak readiness ...\n"
kubectl -n keycloak rollout status deploy/keycloak

kubectl apply -f routes/keycloak-example-com-httproute.yaml

popd

#----------------------------------------- Install Gloo Gateway Portal Postgres DB -----------------------------------------
pushd ../

kubectl create namespace gloo-system --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f portal/postgres.yaml
kubectl apply -f portal/pg-admin.yaml
kubectl apply -f portal/portal-database-config-secret.yaml

printf "\nWait for Portal Database readiness ...\n"
kubectl -n gloo-system rollout status deploy/pgadmin

popd

#----------------------------------------- Install Gloo Gateway with K8S Gateway API support -----------------------------------------

printf "\nInstalling Gloo Gateway $GLOO_GATEWAY_VERSION ...\n"
if [ "$DEV_VERSION" = false ] ; then
  helm upgrade --install gloo glooe/gloo-ee  --namespace gloo-system --create-namespace --set-string license_key=$GLOO_GATEWAY_LICENSE_KEY -f $GLOO_GATEWAY_HELM_VALUES_FILE --version $GLOO_GATEWAY_VERSION
else
  helm upgrade --install gloo gloo-ee-test/gloo-ee  --namespace gloo-system --create-namespace --set-string license_key=$GLOO_GATEWAY_LICENSE_KEY -f $GLOO_GATEWAY_HELM_VALUES_FILE --version $GLOO_GATEWAY_VERSION
fi

printf "\n"


#----------------------------------------- Deploy the Gateway -----------------------------------------
pushd ../

# create the ingress-gw namespace
kubectl create namespace ingress-gw --dry-run=client -o yaml | kubectl apply -f -

printf "\nDeploy the Gateway ...\n"
kubectl apply -f gateways/gw.yaml

popd

#----------------------------------------- Label the gloo-system namespace -----------------------------------------

printf "\nLabel gloo-system namespace ...\n"
kubectl label namespaces gloo-system --overwrite shared-gateway-access="true"