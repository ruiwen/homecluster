
# Create filesystem mount points
etc-mount:
  file.directory:
    - name: /mnt/storage/app-etcd
    - user: root
    - group: root
    - makedirs: True
