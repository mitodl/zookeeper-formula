{%- from 'zookeeper/settings.sls' import zk with context -%}
{% set mirror_data = 'https://www.apache.org/dyn/closer.cgi/zookeeper?as_json=1'|http_query %}
{% set mirror_urls = mirror_data.body|load_json %}
{% set mirror_url = mirror_urls.preferred %}
{% set mirror_backup = mirror_urls.backup[0] %}

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
    - source: {{ mirror_url }}zookeeper/zookeeper-{{ zk.version }}/apache-zookeeper-{{ zk.version }}.tar.gz
    - source_hash: {{ mirror_backup }}zookeeper/zookeeper-{{ zk.version }}/apache-zookeeper-{{ zk.version }}.tar.gz.sha512
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
