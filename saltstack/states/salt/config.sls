
{% set role = 'master' if 'salt-master' in grains['roles'] else 'minion' %}

salt-config:
  file.managed:
    {% if role == 'master' %}
    - name: /etc/salt/master
    - source: salt://salt/config/master
    {% else %}
    - name: /etc/salt/minion
    - source: salt://salt/config/minion
    {% endif %}
    - mode: 644
    - template: jinja
    - makedirs: True
    - dir_mode: 755
    - context:
        master: {{ pillar['master'] }}
        master_fingerprint: {{ pillar['master_fingerprint'] }}

