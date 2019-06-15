{% set configpath = '/mnt/storage/hass/homeassistant' %}


hass-config:
  file.managed:
    - name: {{ configpath }}/configuration.yaml
    - source: salt://hass/config/configuration.yaml

hass-known_devices:
  file.managed:
    - name: {{ configpath }}/known_devices.yaml
    - source: salt://hass/config/known_devices.yaml

hass-automation:
  file.managed:
    - name: {{ configpath }}/automations.yaml
    - source: salt://hass/config/automations.yaml

hass-secret:
  file.managed:
    - name: {{ configpath }}/secrets.yaml
    - source: salt://hass/config/secrets.yaml

hass-local:
  file.directory:
    - name: {{ configpath }}/www
    - makedirs: true

