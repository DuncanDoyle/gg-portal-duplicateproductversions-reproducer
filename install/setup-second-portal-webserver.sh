#!/bin/sh

pushd ../

printf "\nDeploying second Portal WebServer (Note that this is an unsupported setup.\n"
kubectl apply -f portal/gateway-portal-web-server-2.yaml

popd