#!/usr/bin/env bash
apt-get update
apt-get install -y aptitude openssh-server ansible htop
mkdir ~/ansible
cd ~/ansible
cat <<EOT >> ~/ansible/ansible_hosts
127.0.0.1 ansible_connection=local
EOT

cat <<EOT >> ~/ansible/kolibri_playbook.yml
- hosts: 127.0.0.1
  connection: local
  tasks:
    - name: update a server
      apt: update_cache=true
    - name: upgrade a server
      apt: upgrade=full
      
    - name: install htop
      apt: name=htop state=present

    - name: install software-properties
      apt: name=software-properties-common state=present

    - name: load ppa
      apt_repository:  repo='ppa:learningequality/kolibri'
    - name: update a server
      apt: update_cache=true

    - name: install kolibri
      apt: name=kolibri-server state=present

    - name:  Restart Servers
      shell:  reboot
      async:  0
      poll:  0
    - name:  Waiting for restart
      local_action:  wait_for host={{ ansible_ssh_host }} state=started



EOT
export ANSIBLE_HOSTS=~/ansible/ansible_hosts
ansible-playbook -c local -i 127.0.0.1, ~/ansible/kolibri_playbook.yml
