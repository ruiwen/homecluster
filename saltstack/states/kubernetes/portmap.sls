# [This GitHub issue](https://github.com/coreos/flannel/issues/890) mentions
# that the portmap binary is missing from a standard flannel installation
#
# We need to download the portmap binary and install it in /opt/cni/bin

include:
  - kubernetes.packages

{% set portmap_location='/opt/cni/bin/portmap' %}
portmap:
  cmd.run:
    - name: curl -L "https://github.com/projectcalico/cni-plugin/releases/download/v1.9.0/portmap" -o {{ portmap_location }} && chmod a+x {{ portmap_location }}
    - creates: {{ portmap_location }}
    - require:
      - sls: kubernetes.packages



