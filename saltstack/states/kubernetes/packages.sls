# Install the Kubernetes repo and essential packages

{% set kubernetes_version='1.11.0-00' %}
{% set kubernetes_cni_version='0.6.0-00' %}

# If the system has added Google's repo and key before, the key may have expired
# by the time this state is run. We attempt to remove the known expired key (as of 20180727)
# before proceeding
# Ref: https://cloud.google.com/compute/docs/troubleshooting/known-issues#keyexpired
remove-old-google-apt-key:
  module.run:
    - name: pkg.del_repo_key
    - kwargs:
        keyid: A7317B0F

kubernetes-repo:
  pkgrepo.managed:
    - humanname: Kubernetes Repo
    - name: deb http://apt.kubernetes.io/ kubernetes-xenial main
    - key_url: https://packages.cloud.google.com/apt/doc/apt-key.gpg
    - file: /etc/apt/sources.list.d/kubernetes.list
    - clean_file: True
    - refresh: True
    - require_in:
      - kubernetes.packages

kubernetes.packages:
  pkg.installed:
    - fromrepo: kubernetes-xenial
    - refresh: True
    - hold: True
    - update_holds: True
    - pkgs:
      - kubelet: {{ kubernetes_version }}
      - kubeadm: {{ kubernetes_version }}
      - kubectl: {{ kubernetes_version }}
      - kubernetes-cni: {{ kubernetes_cni_version }}
    - require:
      - sls: docker

