kubectl create deployment backend-canary \
  --image=ghcr.io/manwolframio/cdn-backend:v2.2 \
  --replicas=1 \
  -n jiome

kubectl label deployment backend-canary app=backend --overwrite -n jiome

