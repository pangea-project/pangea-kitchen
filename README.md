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

NOTE: you absolutely want to `bundle exec` all knife calls, knife-solo wants
  very specific versions.

# How to Cook

```
# With hostname set up
knife solo cook --clean-up root@drax
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

Note that 9/10 times problems with the cupboard are to do with gpg1 vs. gpg2
setup problems.

# Solo vs. Zero

There's two knifes! knife-solo and then there's knife-zero. But why?! And which
one do we use?

- How solo works: rsyncs the entire kitchen to the remote, then runs chef-solo on
the remote to cook it.
- How zero works: starts chef-zero (lightweight server) on localhost, then
creates an SSH tunnel to the remote, then runs chef-client on the remote to cook
it, which in turn talks to the chef-zero on localhost through the tunnel to get
cookbooks and other resources as needed.

I know, that doesn't tell you why, the why is that zero is
architecturally how chef-server works. Which in turn means the kitchen needs
to be in a chef-server compatible state for it to be usable with knife-zero.
Conversely it means that by using knife-zero we can prepare for a potential
move to chef-server in the future! It's also a tad faster because it does not
have to rsync everything all the time.

All in all functionally there is not much difference though and knife-solo is
easier to not cut yourself with.
If you want you can still play around with zero though.

## How to Cook with Zero

Firstly, zero and solo are not compatible as they want different versions of
net-ssh. So, when using knife-zero you need to change the Gemfile entry from
knife-solo, then run `bundle update` to get suitable versions installed.

Before one can knife a server it needs boostrapping.

```
knife zero bootstrap root@drax --node-name drax --no-converge
```

This bootstraps root@drax (install chef etc.) and assumes its node config is
drax.json (by default the node name is the hostname which almost always is
some stupid stuff for us, so best force a good one). Additionally we'll not
converge the server right now, though you can if you want to.

Cooking/Converging needs a query. The reason for this is that you can
converge multiple hosts at the same time based on the query. See zero docs for
information on this. To only provision one node simply define its name as query.
Additionally since we use bare bones json files for the nodes you'll need to
define a suitable ssh user and hostname (you tell it which attribute is the
hostname and that is the name). Note that as with knife-solo in order for this
to work you need to have the hostname in your ssh config defined.

```
knife zero converge 'name:do-builder-001' --ssh-user root --attribute name
```
