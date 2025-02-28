#!/bin/sh

pushd ..

#----------------------------------------- HTTPBin API Product -----------------------------------------

# Create httpbin namespace if it does not exist yet
kubectl create namespace httpbin2 --dry-run=client -o yaml | kubectl apply -f -

printf "\nDeploy HTTPBin service ...\n"
kubectl apply -f apis/httpbin/httpbin.yaml

printf "\nDeploy HTTPBin Upstream ...\n"
kubectl apply -f upstreams/httpbin-upstream.yaml

printf "\nDeploy HTTPBin APISchemaDiscovery ...\n"
kubectl apply -f apis/httpbin/httpbin-apischemadiscovery.yaml

printf "\nDeploy the HTTPBin HTTPRoute (delegatee) and the HTTP APIProduct ...\n"
kubectl apply -f apiproducts/httpbin2/httpbin2-apiproduct-httproute.yaml
kubectl apply -f apiproducts/httpbin2/httpbin2-apiproduct.yaml
kubectl apply -f referencegrants/httpbin2-ns/portal-gloo-system-apiproduct-rg.yaml
kubectl apply -f referencegrants/httpbin-ns/httproute-httpbin2-service-rg.yaml
kubectl apply -f referencegrants/gloo-system-ns/httproute-httpbin2-upstream-rg.yaml

#----------------------------------------- api.example.com route -----------------------------------------

printf "\nDeploy the api.example.com HTTPRoute ...\n"
kubectl apply -f routes/api-example-com-root-httproute.yaml

popd

