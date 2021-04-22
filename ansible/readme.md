# Ansible


1. Copy the example hosts file into a new one:

```
cp hosts.example hosts
```

2. Populate the hosts, replacing all the `*-server*` items.

3. Run the playbook

```
ansible-playbook -i hosts playbook.yml
```
