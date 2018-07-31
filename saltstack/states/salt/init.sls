
# include:
#   - base
#   - salt.config

{% set salt_version = '2018.3.2+ds-1' %}
{% set role = 'master' if 'salt-master' in grains['roles'] else 'minion' %}

# Ref: https://docs.saltstack.com/en/latest/topics/installation/debian.html
salt-repo:
  pkgrepo.managed:
    - humanname: Salt Repo
    - name: deb http://repo.saltstack.com/apt/debian/9/armhf/latest stretch main
    - file: /etc/apt/sources.list.d/saltstack.list
    - key_url: https://repo.saltstack.com/apt/debian/9/armhf/latest/SALTSTACK-GPG-KEY.pub
    - refresh: True
    - require_in:
      - saltstack-minion
      - saltstack-master

{% for role in ['minion', 'master'] %}
{% if "salt-%s" % role in grains['roles'] %}
saltstack-{{ role }}:
  pkg.installed:
    - refresh: True
    - cache_valid_time: 604800  # 1 week
    - hold: True
    - pkgs:
      - salt-{{ role }}: {{ salt_version }}
    - require:
      - file: saltstack-{{ role }}

  file.managed:
    - name: /etc/salt/{{ role }}
    - source: salt://salt/config/{{ role }}
    - mode: 644
    - template: jinja
    - makedirs: True
    - dir_mode: 755
    - context:
        master: {{ pillar['master'] }}
        master_fingerprint: {{ pillar['master_fingerprint'] }}

  service.running:
    - name: salt-{{ role }}
    - enable: True
    - reload: True
    - watch:
      - file: saltstack-{{ role }}
    - require:
      - pkg: saltstack-{{ role }}
      - file: saltstack-{{ role }}
{% endif %}
{% endfor %}
