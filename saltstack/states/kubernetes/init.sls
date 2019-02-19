
{% set kubernetes_version = '1.13.3' %}

include:
  - base

kubernetes-repo:
  pkgrepo.managed:
    - humanname: Kubernetes Repo
    - name: deb http://apt.kubernetes.io/ kubernetes-xenial main
    - file: /etc/apt/sources.list.d/kubernetes.list
    - key_url: https://packages.cloud.google.com/apt/doc/apt-key.gpgj
    - require_in:
      - kubernetes


kubernetes:
  pkg.installed:
    - pkgs:
      - kubeadm: {{ kubernetes_version }}
      - kubectl: {{ kubernetes_version }}
      - kubelet: {{ kubernetes_version }}
    - hold: True
