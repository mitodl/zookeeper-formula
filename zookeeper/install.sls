{%- from 'zookeeper/settings.sls' import zk with context -%}
{% set mirror_data = 'https://www.apache.org/dyn/closer.cgi/zookeeper?as_json=1'|http_query %}
{% set mirror_paths = mirror_data.body|load_json %}
{% set mirror_path = mirror_paths.preferred %}

zk-user-group:
  group.present:
    - name: {{ zk.group }}
    - gid: {{ zk.gid }}
  user.present:
    - name: {{ zk.user }}
    - home: {{ zk.userhome }}
    - uid: {{ zk.uid }}
    - gid: {{ zk.gid }}
    - require:
      - group: {{ zk.group }}

zk-directories:
  file.directory:
    - user: {{ zk.user }}
    - group: {{ zk.group }}
    - mode: 755
    - makedirs: True
    - names:
      - /var/run/zookeeper
      - /var/lib/zookeeper
      - /var/log/zookeeper

install-zookeeper:
  archive.extracted:
    - name: {{ zk.prefix }}
    - source: {{ mirror_path }}zookeeper/zookeeper-{{ bookkeeper.version }}/apache-zookeeper-{{ bookkeeper.version }}.tar.gz
    - source_hash: {{ mirror_paths.backup[0] }}zookeeper/bookkeeper-{{ bookkeeper.version }}/apache-zookeeper-{{ bookkeeper.version }}.tar.gz.sha512
    - archive_format: tar
    - if_missing: {{ zk.real_home }}/lib
    - user: {{ zk.user }}
    - group: {{ zk.group }}

zookeeper-home-link:
  file.symlink:
    - name: {{ zk.alt_home }}
    - target: {{ zk.real_home }}
    - require:
      - archive: install-zookeeper
