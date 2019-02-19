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
  'roles:app-etcd'
    - match: grain
    - etcd
  'roles:pihole'
    - match: grain
    - pihole
  'roles:hass'
    - match: grain
    - hass

