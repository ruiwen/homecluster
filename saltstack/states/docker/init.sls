# Installs Docker and configures the daemon for persistent restarts

{% set docker_version = '5:18.09.0~3-0~raspbian-stretch' %}
# {% set docker_version = '18.06.1~ce~3-0~raspbian' %}

docker-repo:
  pkgrepo.managed:
    - humanname: Docker Repo
    - name: deb https://download.docker.com/linux/raspbian {{ grains['oscodename'] }} stable
    - key_url: https://download.docker.com/linux/ubuntu/gpg
    - file: /etc/apt/sources.list.d/docker.list
    - clean_file: True
    - architectures: armhf
    - refresh: True

# Ref: https://docs.docker.com/engine/admin/live-restore/
# In case the node already has dockerd running
docker-daemon:
  file.managed:
    - name: /etc/docker/daemon.json
    - makedirs: true
    - source: salt://docker/config/daemon.json
    - require:
      - pkgrepo: docker-repo

docker-ce:
  pkg.installed:
    # - fromrepo: {{ grains['oscodename'] }}
    - version: {{ docker_version }}
    - refresh: true
    - hold: true
    - update_holds: true
    - require:
      - pkgrepo: docker-repo

# aufs-tools:
#   pkg.installed:
#     - require:
#       - pkg: docker-ce

docker:
  service.running:
    - enable: True
    - reload: True
    - require:
      - pkg: docker-ce
    - watch:
      - file: /etc/docker/daemon.json

