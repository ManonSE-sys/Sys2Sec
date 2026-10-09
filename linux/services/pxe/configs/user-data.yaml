#cloud-config
autoinstall:
  apt:
    disable_components: []
    geoip: true
    preserve_sources_list: false
    primary:
    - arches:
        - amd64
        - i386
        uri: http://fr.archive.ubuntu.com/ubuntu
    - arches:
        - default
        uri: http://ports.ubuntu.com/ubuntu-ports
  drivers:
    install: false
  identity:
    hostname: ubuntu-server
    password:
    realname: local
    username: local
  kernel:
    package: linux-generic
  keyboard:
    layout: fr
    toggle: null
    variant: ''
  locale: fr_FR.UTF-8
  timezone: "Europe/Paris"
  ssh:
    allow-pw: true
    authorized-keys: []
    install-server: true
  storage:
    layout:
    	name: direct
    	match: {}
  updates: security
  late-commands:
