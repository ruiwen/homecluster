
pihole-data:
  file.directory:
    - name: /mnt/storage/pihole/pihole
    - user: root
    - group: root
    - makedirs: true

dnsmasq-data:
  file.directory:
    - name: /mnt/storage/pihole/dnsmasq
    - user: root
    - group: root
    - makedirs: true
