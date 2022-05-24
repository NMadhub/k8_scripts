#!/bin/bash

init_Cluster()
{
        swapoff -a
        kubeadm init >> ./ClusterInit_Logs.txt
        kubeadm token create --print-join-command >> ./JoinNodeToken.txt
        mkdir /home/nvidia/.kube
        cp -r /etc/kubernetes/admin.conf /home/nvidia/.kube/config
        chown -R nvidia:nvidia /home/nvidia/.kube
        export KUBECONFIG=/etc/kubernetes/admin.conf

}

launch_NetworkCNI_Calico()
{
        kubectl apply -f https://docs.projectcalico.org/v3.11/manifests/calico.yaml
}

launch_NvidiaPlugin()
{

        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
        helm repo add nvgfd https://nvidia.github.io/gpu-feature-discovery
        helm repo update
        helm install --version=0.9.0 --generate-name --set compatWithPUManager=true --set migStrategy=mixed nvdp/nvidia-device-plugin
        helm install --version=0.4.1 --set migStrategy=mixed gpu-feature-discovery nvgfd/gpu-feature-discovery

}

untaint_Node()
{
        kubectl taint nodes -all node-role.kubernetes.io/master-
}

init_Cluster

set_AdminConfig

launch_NetworkCNI_Calico

launch_NvidiaPlugin

watch kubectl get pods --all-namespaces
