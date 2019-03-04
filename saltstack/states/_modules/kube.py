import logging

log = logging.getLogger(__name__)


def post_init():

    if __salt__['file.file_exists']('/tmp/k8s/join_token') and __salt__['file.file_exists']('/tmp/k8s/ca_hash'):

        join_token = __salt__['file.read']('/tmp/k8s/join_token')
        ca_hash = __salt__['file.read']('/tmp/k8s/ca_hash')

        __salt__['event.send'](
                    'kubernetes/cluster/init',
                    {
                        "name": __grains__['kubernetes']['cluster']['name'],
                        "join_token": join_token,
                        "ca_hash": ca_hash
                    }
                )

        __salt__['grains.set'](
                    'kubernetes:cluster:join_token',
                    val=join_token
                )

        __salt__['grains.set'](
                    'kubernetes:cluster:ca_hash',
                    val=join_token
                )


def join():
    """
    Attempts to join a Kubernetes cluster, unless the file
    /etc/kubernetes/kubelet.conf is already present on the system
    """

    if not __salt__['file.file_exists']('/etc/kubernetes/kubelet.conf'):
        log.info("Attempting to join cluster: %s" % (__grains__['kubernetes']['cluster']['name']))
        __salt__['cmd.run'](
                    "kubeadm join --node-name=%s --token=%s --discovery-token-ca-cert-hash=%s %s:%s" % (
                           __grains__['localhost'],
                           __grains__['kubernetes']['cluster']['join_token'],
                           __grains__['kubernetes']['cluster']['ca_hash'],
                           __pillar__['kubernetes']['cluster']['master_host'],
                           __pillar__['kubernetes']['cluster']['master_port']
                        ),
                    creates=__pillar__['kubernetes']['pool_config']
                )
    else:
        log.info("/etc/kubernetes/kubelet.conf already present, skipping joining cluster")

