
custom-dns:
  file.managed:
    - name: /mnt/storage/pihole/dnsmasq/custom.conf
    - contents: |
        address=/pihole.lab/192.168.1.202
        address=/hass.lab/192.168.1.203
