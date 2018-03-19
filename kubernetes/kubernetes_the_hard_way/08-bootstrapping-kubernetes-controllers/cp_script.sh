#!/bin/bash

for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp bootstrap_kubernetes_controllers.sh rbac.sh ${instance}:~/
done
