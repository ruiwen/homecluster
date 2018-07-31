base:
  '*':
    - base
  'roles:salt*':
    - match: grain
    - salt
  'roles:kubernetes':
    - match: grain
    - kubernetes
