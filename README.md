# Requirements

- Ruby 2.1
- SSH access to relevant hosts
- For convenience a .ssh/config entry to make the hosts name accessible (e.g. map IP to hostname such as 'drax' or 'taspar')

# Prerequisites

```
bundle install
librarian-chef install
```

# How to Cook

```
# With hostname set up
knife solo cook root@drax
```

```
# Without hostname set up (manual file definition)
knife solo cook root@192.168.0.9 nodes/drax.json
```

```
# With verbosity
knife solo cook -V root@drax
```

```
# Without librarian cache check
knife solo cook -V root@drax --no-librarian
```

