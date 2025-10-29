
# Connected-Kiln
### Objectives:
1. Begin collecting operational data from real world cermaics kilns using Ardunio hardware
2. Publish operational data to a cloud-based datastore
3. Leverage the data generated to create a tinyML model that provides predictive features to the kiln operation
4. Evaluate if the resulting ML model could be leveraged for combustion controls

### Hope to achieve:
- Increased fuel efficiency
- Firing automation for natural gas kiln, including temperature down ramps
- Strict reduction control to optimize glaze performance and fuel consumption


## Prerequisites
For this project, we're using a k3s Cluster, on site (LAN / WIFI)

````
Client Version: v1.32.0
Kustomize Version: v5.5.0
Server Version: v1.31.9+k3s1
````
3 node master VM's running Redhat Linux 9.5, 2 CPU / 32 GB Memory / 200GB Storage each.
Host Server: Dell Edge 150 with Load Balancer HAPROXY to manage communications to the cluster

Key microservices in place (in addition to default k3s features:

- Grafana-Loki-Alloy: Log Analytics
- Cert Manager: Certificate management and automation
- Istio (Kubernetes Gateway) : Ingress controls
- Longhorn: Distributed Block Storage Platform
- Sealed Secrets: Encryption of kubernetes secrets
- Schooner: Kubernetes Dashboard
- Velero: Backup / Recovery (Backblaze off site storage)

## Detailed Kubernetes Components

![img_1.png](images/img_1.png)
## Initialization

Using kubectl, implement the new namespace to organize the needed microservices
````
kubectl apply -f connected-kiln-ns.yaml
````
This command will create the connected-kiln namespace that is used throughout the configuration. Additionally, connecting
to the schooner dashboard is helpful:
````
kubectl port-forward service/skooner 8000:80 -n kube-system
````
Always good to create a full backup of the kubernetes system to be able to UNDO all that we're going to do. Here are some helful Velero commands:
````
velero backup get
NAME                        STATUS      ERRORS   WARNINGS   CREATED                         EXPIRES   STORAGE LOCATION   SELECTOR
full-daily-20251029080048   Completed   0        0          2025-10-29 04:00:48 -0400 EDT   6d        default            <none>
full-daily-20251028080047   Completed   0        2          2025-10-28 04:00:47 -0400 EDT   5d        default            <none>
special-full-10-27          Completed   0        2          2025-10-27 11:30:43 -0400 EDT   28d       default            <none>
````
The special back up was created using the following command:
````
velero backup create special-full-10-27
````
Create a working directory on your local client and make sure the following CLI tools are avaliable:
- kubectl (also, you are connected to your local/remote kubernetes cluster)
- velero (if you have implemented velero as your cluster backup tooling)

git clone git@github.com
## Eclipse Mosquitto Broker

Installation steps:

Step 1: Run the following kubectl commands:
````
cd /connected
kubectl apply -f mosquitto-pvc.yaml