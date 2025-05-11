# Se ve que ha pasado
kubectl rollout history deployment backend-deployment -n jiome
# Se hace un rollback
kubectl rollout undo deployment backend-deployment -n jiome
# Se ve como esta
kubectl rollout history deployment backend-deployment -n jiome


