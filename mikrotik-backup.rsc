---
- hosts: router
  gather_facts: no
  tasks:
  - set_fact:
      time="{{ lookup('pipe', 'date +%Y%m%d-%H%M%S')}}"
      savepath="/mnt/media/temp"
  - name: Run backup
    routeros_command:            
      commands: 
        - /file remove [find where name~".backup"]
        - /file remove [find where name~".rsc"]
        - /system backup save encryption=aes-sha256 name={{inventory_hostname}}-{{time}}
        - /export compact file={{inventory_hostname}}-{{time}}
#    register: out
#  - debug: var=out.stdout_lines
  - name: Copy rsc file
    command: sftp {{inventory_hostname}}:{{inventory_hostname}}-{{time}}.rsc {{savepath}}
  - name: Copy backup file
    command: "{{ item }}"
    with_items:
      - sftp {{inventory_hostname}}:{{inventory_hostname}}-{{time}}.backup {{savepath}}
      - sftp {{inventory_hostname}}:flash/{{inventory_hostname}}-{{time}}.backup {{savepath}}
    args:
      warn: no
    ignore_errors: yes
    no_log: true
  - name: Clear commands hostory
    routeros_command:
      commands:
        - /console clean
