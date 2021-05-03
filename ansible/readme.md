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

## Memory Use

Building Web and FTL steps involve compilation and need at least 2G - 3G or so. 

Easy fix on miniture nodes is to add a 4G swap to /swapfile (doesn't persist reboots)
```
dd if=/dev/zero of=/swapfile bs=1k count=4M && mkswap /swapfile && chmod 600 /swapfile && swapon /swapfile
```

## Rough Non-Prod Building notes

### Web

* The elixir and apt/package installs are commented out of the tasks (though need to be installed)
* If you're Ansible login user is not root, the `npm` commands will fail as they will subshell as your unpriviliged user. Running manually as root resolves.
* PostgreSQL is needed (either DBaaS or on node) - `apt install postgresql && pg_ctlcluster 12 main start` [Glimesh.tv docs here](https://github.com/Glimesh/glimesh.tv#configuring-postgres)
* The DB will need to be initiliazed `mix ecto.setup` will create a glimesh_dev DB
* Ensure `glimesh_url_host` and `glimesh_database_url` are set correctly


Important queries for non-Prod testing:
```
# Verify users email (without a valid Mailgun / SMTP host):
UPDATE users SET confirmed_at = current_timestamp where username = 'test_user';

# Set a user as Admin
UPDATE users SET is_admin = true where username = 'test_user';

# Add a created FTL Edge to the Frontend
INSERT into janus_edge_routes (hostname, url, available, inserted_at, updated_at) VALUES ('edge.example.com', 'https://edge.example.com/janus', true, current_timestamp, current_timestamp)
```

(_Note: you must connect to the Glimesh DB first eg. `\c db_name`_)

### FTL

* The Ingest needs an ID/secret from the Frontend. The configured Admin creates an Application - set the `glimesh_client_id` and `glimesh_client_secret` based on this
* `ftl_orchestrator_psk` is shared among Orchestrator, Ingest and Edge
* `ftl_orchestrator_hostname` is a valid DNS record for the Ingest/Edge to reach Orchestrator
* `glimesh_api_hostname` will need to point to the Web node (and check the port/scheme values)
* Further configuration details [here](https://github.com/Glimesh/janus-ftl-plugin#configuration)
* Update the Frontend Edge routing table (see Web queries above)
* After creating a Channel in Frontend, OBS Streaming instructions then [here](https://github.com/Glimesh/janus-ftl-plugin#streaming-from-obs)
