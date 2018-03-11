# ansible-role-libvirt

Install `libvirt`

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `libvirt_package` | Package name of `libvirt` | `{{ __libvirt_package }}` |
| `libvirt_extra_packages` | List of additional packages to install | `[]` |
| `libvirt_service` | Service name of `libvirtd` | `{{ __libvirt_service }}` |
| `libvirt_conf_dir` | Path to configuration directory | `{{ __libvirt_conf_dir }}` |
| `libvirt_config` | List of configuration files (see below) | `[]` |
| `libvirt_flags` | Flags for `libvirtd` (see below) | `{}` |

## `libvirt_config`

This variable is a list of dict. Keys of the dict are explained below.

| Key | Value | Mandatory? |
|-----|-------|------------|
| `name` | base file name of the file | yes |
| `state` | Either `absent` or `present` | yes |
| `mode` | Mode of the file | no |
| `owner` | Owner of the file | no |
| `group` | Group of the file | no |
| `content` | The content of the file | no |

## `libvirt_flags`

This variable is a dict of flags and extra variables for start-up scripts.
Keys and values are expanded as `key="value"'. See the example below.

## FreeBSD

| Variable | Default |
|----------|---------|
| `__libvirt_package` | `libvirt` |
| `__libvirt_service` | `libvirtd` |
| `__libvirt_conf_dir` | `/usr/local/etc/libvirt` |

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - ansible-role-libvirt
  vars:
    libvirt_config:
      - name: removeme.conf
        state: absent
      - name: libvirtd.conf
        state: present
        mode: 640
        owner: root
        group: "{% if ansible_os_family == 'RedHat' %}daemon{% else %}operator{% endif %}"
        content: |
          log_level = 2
          {% if ansible_os_family == 'Debian' %}
          unix_sock_group = "libvirtd"
          unix_sock_ro_perms = "0777"
          unix_sock_rw_perms = "0770"
          auth_unix_ro = "none"
          auth_unix_rw = "none"
          {% elif ansible_os_family == 'RedHat' %}
          unix_sock_group = "libvirt"
          unix_sock_ro_perms = "0777"
          unix_sock_rw_perms = "0770"
          auth_unix_ro = "none"
          auth_unix_rw = "none"
          {% endif %}
    libvirt_extra_packages: "{% if ansible_os_family == 'FreeBSD' %}[ 'sysutils/grub2-bhyve' ]{% elif ansible_os_family == 'Debian' %}[ 'qemu-kvm' ]{% elif ansible_os_family == 'RedHat' %}[ 'qemu-kvm' ]{% endif %}"

    freebsd_flags:
      libvirtd_flags: "--config {{ libvirt_conf_dir }}/libvirtd.conf"
    ubuntu_flags:
      start_libvirtd: "yes"
      libvirtd_opts: "--config {{ libvirt_conf_dir }}/libvirtd.conf"
    redhat_flags:
      LIBVIRTD_ARGS: "--config {{ libvirt_conf_dir }}/libvirtd.conf"
    libvirt_flags: "{% if ansible_os_family == 'FreeBSD' %}{{ freebsd_flags }}{% elif ansible_os_family == 'Debian' %}{{ ubuntu_flags }}{% elif ansible_os_family == 'RedHat' %}{{ redhat_flags }}{% endif %}"
```

# License

```
Copyright (c) 2018 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)
