# Reacts to a kubernetes/cluster/init event, expecting the following data
#   join_token: <string>
#   ca_hash: <string>
#
#   Based on the output of from the salt highstate, we see the event data being sent not as
#
#   {
#     "join_token": "thisisjointoken",
#     "ca_hash": "thisiscahash"
#   }
#
#   but as
#
#   {
#     "data": {
#       "join_token": "thisisjointoken",
#       "ca_hash": "thisiscahash"
#     }
#   }
#
#  So when extracting the values to set our grains, we need to use data['data']['join_token'], instead of
#  just data['join_token']

# kubernetes-cluster-init-echo:
#   local.cmd.run:
#     - name: feedback
#     - tgt: 'roles:kube*'
#     - args:
#       - cmd: 'echo [KUBERNETESCLUSTERINIT]: {{ data|json|escape }}'

# While we target 'role:kubernetes' here, the grains don't actually get set on the kubemaster
# when the reactor state runs because kubemaster is usually still busy running the state to
# initialise the kubernetes cluster
kubernetes-init-grains:
  local.state.single:
    - tgt: 'roles:kubernetes'
    - tgt_type: grain
    - args:
      - fun: grains.present
      - name: kubernetes:cluster
      - force: True
      - value:
          name: "{{ data['data']['name'] }}"
          join_token: "{{ data['data']['join_token'] }}"
          ca_hash: "{{ data['data']['ca_hash'] }}"

