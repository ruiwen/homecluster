# We use this state to have a node join a cluster
# We can target specific nodes to join specific clusters (with join tokens in pillars),
# based on the grains set on the node

join-cluster:
  module.run:
    - name: kube.join
    - require:
      - sls: kubernetes.packages
      - sls: kubernetes.portmap

