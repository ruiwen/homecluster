base:
  '*':
    - base
  'roles:salt*':
    - match: grain
    - salt
  'roles:kubernetes':
    - match: grain
    - docker
    - kubernetes.packages
    # - kubernetes.portmap
  'roles:kubernetes-master':
    - match: grain
    - kubernetes.cluster.init
  'roles:kubernetes-pool':
    - match: grain
    - kubernetes.cluster.join
  'roles:app-etcd'
    - match: grain
    - etcd
  'roles:pihole'
    - match: grain
    - pihole
    - pihole.custom
  'roles:hass'
    - match: grain
    - hass
    - hass.config

