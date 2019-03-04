# Attempts to initialise the Kubernetes master
# Should only be run on the node designated as the kubernetes-master
# Details to be passed to kubeadm, can be set in the pillar

# We run kubeadm init in a cmd.run_stdout call in order to save the output
# to the ca_hash variable, so we can include the CA hash of the API server
# in the kubernetes/cluster/init event below.
# We grep and extract the output of 'kubeadm init' in order to extract the
# CA hash.
# We'd have no other way of retaining the output of the command if we ran it
# as part of a normal Salt state

kubernetes-packages-init:
  cmd.run:
    - name: "echo 'Installing Kubernetes'"
    - watch:
      - sls: kubernetes.packages

kubernetes-tmp:
  file.directory:
    - name: /tmp/k8s
    - clean: True

kubernetes-init:
  cmd.script:
    - source: salt://kubernetes/cluster/scripts/kubeadm-init.sh
    - template: jinja
    - creates: {{ pillar['kubernetes']['pool_config'] }}

kubernetes-grains:
  module.run:
    - name: saltutil.sync_grains

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
    - requires:
      - cmd: kubernetes-init
    - unless: test -f {{ pillar['kubernetes']['pool_config'] }}

# kubernetes-install-canal-rbac:
#   cmd.run:
#     - name: kubectl apply -f /tmp/{{ random_path }}/canal-rbac.yaml
#     - onlyif: test -f /etc/kubernetes/kubelet.conf
#     - env:
#       - kubeconfig: /etc/kubernetes/admin.conf
#     - requires:
#       - file: kubernetes-cni-install-script
#       - cmd: kubernetes-init
#     - unless: test -f {{ pillar['kubernetes']['pool_config'] }}
#
# kubernetes-install-canal:
#   cmd.run:
#     - name: kubectl apply -f /tmp/{{ random_path }}/canal.yaml
#     - onlyif: test -f /etc/kubernetes/kubelet.conf
#     - env:
#       - KUBECONFIG: /etc/kubernetes/admin.conf
#     - requires:
#       - file: kubernetes-cni-install-script
#       - cmd: kubernetes-init
#     - unless: test -f {{ pillar['kubernetes']['pool_config'] }}

kubernetes-install-flannel:
  cmd.run:
    - name: kubectl apply -f /tmp/{{ random_path }}/flannel.yaml
    - onlyif: test -f /etc/kubernetes/kubelet.conf
    - env:
      - KUBECONFIG: /etc/kubernetes/admin.conf
    - requires:
      - file: kubernetes-cni-install-script
      - cmd: kubernetes-init
    - unless: test -f {{ pillar['kubernetes']['pool_config'] }}

kubernetes-cni-remove-script:
  file.absent:
    - name: /tmp/{{ random_path }}/
    - requires:
      - file: kubernetes-cni-install-script
      - cmd: kubernetes-install-flannel
      # - cmd: kubernetes-install-canal-rbac
      # - cmd: kubernetes-install-canal

# Once the Kubernetes cluster and CNI layer is initialised, we activate the post_init module
# to
# a) fire a kubernetes/cluster/init event into the Salt event bus. This allows us to kick off multiple other
#    events that need to react to the Kubernetes cluster being initialised.
#    We use the Salt Reactor system to react to the event, and publish the grain values on the kubernetes-pool nodes
# b) set grains related to the join token and CA cert hash on the kubemaster node, same as what we will set
#    on the kubernetes-pool minions
#
# We use a custom module here because our kubeadm-init script extracts the generated value of the CA cert hash,
# (and potentially the join token) and write them both to temporary files. It's generally difficult to retrieve
# values from files into Salt states, so we do that in a Python module instead.
kubeadm-init-done:
  module.run:
    - name: kube.post_init
    - requires:
      - cmd: kubernetes-init

