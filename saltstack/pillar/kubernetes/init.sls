# Here we set the various values for each cluster
# Ideally, just based off the cluster_name, we'd be able to pull the appropriate
# values from envvars, instead of hardcoding them in the file

{% set cluster_name = salt['grains.get']('kubernetes', {}).get('cluster').get('name') %}
# {% set token = salt['environ.get']("KUBERNETES_%s_TOKEN" % cluster_name) %}
# {% set master_host = salt['environ.get']("KUBERNETES_%s_MASTER_HOST" % cluster_name) %}
# {% set master_port = salt['environ.get']("KUBERNETES_%s_MASTER_PORT" % cluster_name) %}

kubernetes:
  pool_config: /etc/kubernetes/kubelet.conf
  cluster:
    {% if cluster_name == 'home' %}
    token:
    master_host: 192.168.1.201
    master_port: 6443
    # features: Auditing=true
    service_cidr: 10.96.0.0/12
    pod_cidr: 10.244.0.0/16
    {% endif %}

