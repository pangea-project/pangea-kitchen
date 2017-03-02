# Requirements

- Ruby 2.1
- SSH access to relevant hosts
- For convenience a .ssh/config entry to make the hosts name accessible (e.g. map IP to hostname such as 'drax' or 'taspar')

# Prerequisites

```
bundle install
berks install # lock cookbook dependencies
berks vendor  # install cookbook dependencies in berks-cookbooks
```

# How to Cook

```
# With hostname set up
knife solo cook --clean-up croot@drax
```

```
# Without hostname set up (manual file definition)
knife solo cook --clean-up root@192.168.0.9 nodes/drax.json
```

```
# With verbosity
knife solo cook -V --clean-up root@drax
```

# Secrets storage - aka Cupboard

Knife commands automatically will setup the `data_bags/cupboard/`` submodule,
it includes encrypted secret blobs such as SSH keys. For more information see
the cupboard README.
