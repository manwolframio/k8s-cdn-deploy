
# Documentación de Despliegue de Backend en Kubernetes

Este documento describe cómo desplegar un **backend** en Kubernetes utilizando un **Ingress Controller**, un **Service** para balanceo de tráfico entre réplicas y un **Deployment** con 4 réplicas de Pods.

## 1. Creación del Namespace `jiome`

El **Namespace** `jiome` se debe crear para agrupar todos los recursos relacionados con la aplicación. Si el namespace no existe, el siguiente comando debe aplicarse:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: jiome
```

**Aplicar el archivo:**
```bash
kubectl apply -f namespace-jiome.yaml
```

---

## 2. Deploy de los Pods de Backend

El archivo `backend-deployment.yaml` define el **Deployment** para los Pods de backend. Se lanzan **4 réplicas** de la imagen de backend, cada una escuchando en el puerto 80.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-deployment
  namespace: jiome
spec:
  replicas: 4
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: ghcr.io/tecinternet-muit-uah/ti_backend_project:v1.0
        ports:
        - containerPort: 80
```

**Aplicar el archivo:**
```bash
kubectl apply -f backend-deployment.yaml
```

---

## 3. Crear el Service para Balanceo de Tráfico

El archivo `backend-service.yaml` define un **Service de tipo ClusterIP**. Este Service balancea las peticiones entre las 4 réplicas del backend.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: jiome
spec:
  selector:
    app: backend
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
```

**Aplicar el archivo:**
```bash
kubectl apply -f backend-service.yaml
```

---

## 4. Desplegar el Ingress Controller

El archivo `backend-ingress-controller-deployment.yaml` define el **Ingress Controller** que maneja las peticiones HTTP hacia el `backend-service`. Este Controller escucha en el puerto 80 de cada nodo (con `HostPort`).

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-ingress-controller
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend-ingress-controller
  template:
    metadata:
      labels:
        app: backend-ingress-controller
    spec:
      containers:
      - name: controller
        image: k8s.gcr.io/ingress-nginx/controller:v1.7.0
        args:
          - /nginx-ingress-controller
          - --ingress-class=backend-ingress
        ports:
          - containerPort: 80
            hostPort: 80
```

**Aplicar el archivo:**
```bash
kubectl apply -f backend-ingress-controller-deployment.yaml
```

---

## 5. Crear las Reglas de Ingress

El archivo `backend-ingress.yaml` define las reglas del **Ingress**, que redirigen el tráfico HTTP hacia el `backend-service`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: backend-ingress
  annotations:
    kubernetes.io/ingress.class: backend-ingress
spec:
  rules:
  - host: backend.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 80
```

**Aplicar el archivo:**
```bash
kubectl apply -f backend-ingress.yaml
```

---

## Flujo Total de la Arquitectura de Backend

1. **Namespace `jiome`**: Define el espacio para todos los recursos.
2. **`backend-deployment.yaml`**: Lanza 4 Pods backend.
3. **`backend-service.yaml`**: El Service balancea el tráfico entre las 4 réplicas de backend.
4. **`backend-ingress-controller-deployment.yaml`**: Despliega el Ingress Controller (NGINX) que maneja las peticiones HTTP.
5. **`backend-ingress.yaml`**: Define las reglas del Ingress que redirigen el tráfico hacia el `backend-service`.

---

## Comando Completo para Aplicar los Recursos

Si ya tienes el archivo `namespace-jiome.yaml` (para crear el Namespace), el orden correcto para aplicar los recursos es el siguiente:

```bash
kubectl apply -f namespace-jiome.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
kubectl apply -f backend-ingress-controller-deployment.yaml
kubectl apply -f backend-ingress.yaml
```

---

 
- 4 Pods backend.
- Balanceo de tráfico entre los Pods usando un Service.
- Exposición del backend mediante un Ingress Controller.
- Redirección del tráfico al `backend-service` basado en las reglas de Ingress.

