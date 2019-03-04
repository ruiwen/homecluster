
hass-config:
  file.managed:
    - name: /mnt/storage/hass/config/configuration.yaml
    - source: salt://hass/config/configuration.yaml

hass-known_devices:
  file.managed:
    - name: /mnt/storage/hass/config/known_devices.yaml
    - source: salt://hass/config/known_devices.yaml

hass-local:
  file.directory:
    - name: /mnt/storage/hass/config/www
    - makedirs: true
