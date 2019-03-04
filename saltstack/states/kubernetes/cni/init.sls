# Initialise the networking layer for our Kubernetes cluster
# We're using Canal (Calico + Flannel)
#
# Ref: https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/flannel
#
# For other CNI plugins, see https://kubernetes.io/docs/concepts/cluster-administration/addons/

{% set random_path = salt['random.get_str'](20) %}

kubernetes-cni-install-script:
  file.recurse:
    - name: /tmp/{{ random_path }}/
    - source: salt://kubernetes/cni/config/
    - clean: True

kubernetes-install-canal-rbac:
  cmd.run:
    - name: kubectl apply -f /tmp/{{ random_path }}/canal-rbac.yaml
    - onlyif: test -f /etc/kubernetes/kubelet.conf
    - env:
      - KUBECONFIG: /etc/kubernetes/admin.conf
    - requires:
      - file: kubernetes-cni-install-script

kubernetes-install-canal:
  cmd.run:
    - name: kubectl apply -f /tmp/{{ random_path }}/canal.yaml
    - onlyif: test -f /etc/kubernetes/kubelet.conf
    - env:
      - KUBECONFIG: /etc/kubernetes/admin.conf
    - requires:
      - file: kubernetes-cni-install-script

kubernetes-cni-remove-script:
  file.absent:
    - name: /tmp/{{ random_path }}/
