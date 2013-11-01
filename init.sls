{%- if pillar.redmine.enabled %}

include:
  - git
  - ruby

/srv/redmine/sites:
  file:
  - directory
  - mode: 755
  - makedirs: true

{%- for app in pillar.redmine.apps %}
redmine_packages:
  pkg:
  - installed
  - names:
    {%- if pillar.redmine.version == '2.3' %}
    - libxslt-dev
    - libxml2-dev
    {%- endif %}
    {%- if app.database.engine == 'mysql' %}
    - libmysqlclient-dev    
    {%- endif%}
    {%- if app.database.engine == 'sqlserver' %}
    - freetds-dev
    {%- endif%}
    - libmagickwand-dev
    - imagemagick
#    - graphicsmagick-libmagick-dev-compat
    - libsqlite3-dev
    - libpq-dev

rails:
  gem:
  - installed

rake:
  gem:
  - installed

i18n:
  gem:
  - installed

mocha:
  gem:
  - installed

{%- if app.database.engine == 'mysql' %}
mysql:
  gem:
  - installed
  - require:
    - pkg: libmysqlclient-dev
{%- endif%}
{%- if app.database.engine == 'postgresql' %}
pg:
  gem:
  - installed
{%- endif %}
{%- if app.database.engine == 'sqlserver' %}
tiny_tds:
  gem: 
  - installed
activerecord-sqlserver-adapter:
  gem:
  - installed
{%- endif%}
repo-{{ app.name }}:
  git.latest:
  - name: https://github.com/redmine/redmine
  - target: /srv/redmine/sites/{{ app.name }}
  - runas: root
  - rev: {{ pillar.redmine.version }}-stable
  - require:
    - file: /srv/redmine/sites
    - pkg: git

/srv/redmine/sites/{{ app.name }}/config/configuration.yml:
  file:
  - managed
  - source: salt://redmine/conf/configuration.yml
  - template: jinja
  - defaults:
    app_name: "{{ app.name }}"
  - require:
    - git: repo-{{ app.name }}

/srv/redmine/sites/{{ app.name }}/config/database.yml:
  file:
  - managed
  - source: salt://redmine/conf/database.yml
  - template: jinja
  - defaults:
    app_name: "{{ app.name }}"
  - require:
    - git: repo-{{ app.name }}

install_redmine_{{ app.name }}:
  cmd.run:
    - name: bundle install
    - cwd: /srv/redmine/sites/{{ app.name }}
    - require:
      - file: /srv/redmine/sites/{{ app.name }}/config/database.yml
      - pkg: redmine_packages

init_session_redmine_{{ app.name }}:
  cmd.run:
    - name: rake generate_secret_token
    - cwd: /srv/redmine/sites/{{ app.name }}
    - require:
      - file: /srv/redmine/sites/{{ app.name }}/config/database.yml
      - pkg: redmine_packages
      - cmd: install_redmine_{{ app.name }}

init_database_redmine_{{ app.name }}:
  cmd.run:
    - name: 'rake db:migrate RAILS_ENV="production"'
    - cwd: /srv/redmine/sites/{{ app.name }}
    - require:
      - file: /srv/redmine/sites/{{ app.name }}/config/database.yml
      - pkg: redmine_packages
      - cmd: init_session_redmine_{{ app.name }}

/srv/redmine/sites/{{ app.name }}/files:
  file:
  - directory
  - mode: 755
  - user: www-data
  - group: www-data
  - require:
    - git: repo-{{ app.name }}

/srv/redmine/sites/{{ app.name }}/log:
  file:
  - directory
  - mode: 755
  - user: www-data
  - group: www-data
  - require:
    - git: repo-{{ app.name }}

/srv/redmine/sites/{{ app.name }}/log/production.log:
  file:
  - managed
  - mode: 666
  - require:
    - file: /srv/redmine/sites/{{ app.name }}/log

/srv/redmine/sites/{{ app.name }}/tmp:
  file:
  - directory
  - mode: 755
  - user: www-data
  - group: www-data
  - require:
    - git: repo-{{ app.name }}

/srv/redmine/sites/{{ app.name }}/public/plugin_assets:
  file:
  - directory
  - mode: 755
  - user: www-data
  - group: www-data
  - require:
    - git: repo-{{ app.name }}

{%- if app.plugins is defined %}
{%- for plugin in app.plugins %}

{%- if plugin.name == 'theme_changer' %}

download_theme_changer:
  cmd.run:
  - name: wget https://bitbucket.org/haru_iida/redmine_theme_changer/downloads/redmine_theme_changer-0.1.0.zip
  - unless: "[ -f /root/redmine_theme_changer-0.1.0.zip ]"
  - cwd: /root
  - require:
    - cmd: install_redmine_{{ app.name }}

install_theme_changer:
  cmd.run:
  - name: unzip redmine_theme_changer-0.1.0.zip -d /srv/redmine/sites/{{ app.name }}/plugins/
  - unless: "[ -d /srv/redmine/sites/{{ app.name }}/plugins/redmine_theme_changer ]"
  - cwd: /root
  - require:
    - cmd: download_theme_changer

{%- elif plugin.name == 'wiki_template' %}

download_wiki_template:
  cmd.run:
  - name: wget https://github.com/generaldesoftware/RedMine-plantillas-plugin/archive/master.zip
  - unless: "[ -f /root/master.zip ]"
  - cwd: /root
  - require:
    - cmd: install_redmine_{{ app.name }}

unzip_wiki_template:
  cmd.run:
  - name: unzip master.zip
  - unless: "[ -d /root/RedMine-plantillas-plugin-master ]"
  - cwd: /root
  - require:
    - cmd: download_wiki_template

install_wiki_template:
  cmd.run:
  - name: mv /root/RedMine-plantillas-plugin-master /srv/redmine/sites/{{ app.name }}/plugins/redmine_gsc_plantillas
  - unless: "[ -d /srv/redmine/sites/{{ app.name }}/plugins/redmine_gsc_plantillas ]"
  - cwd: /root
  - require:
    - cmd: unzip_wiki_template

{%- elif plugin.name == 'crm' %}

download_crm:
  cmd.run:
  - name: wget http://www.redminecrm.com/license_manager/6162/redmine_contacts-3_2_4-light.zip
  - unless: "[ -f /root/redmine_contacts-3_2_4-light.zip ]"
  - cwd: /root
  - require:
    - cmd: install_redmine_{{ app.name }}

unzip_crm:
  cmd.run:
  - name: unzip redmine_contacts-3_2_4-light.zip -d /srv/redmine/sites/{{ app.name }}/plugins/
  - unless: "[ -d /srv/redmine/sites/{{ app.name }}/plugins/redmine_contacts ]"
  - cwd: /root
  - require:
    - cmd: download_crm

install_crm:
  cmd.run:
  - name: bundle install --without development test
  - cwd: /srv/redmine/sites/{{ app.name }}/plugins/redmine_contacts
  - unless: "[ -d /srv/redmine/sites/{{ app.name }}/plugins/redmine_contacts ]"
  - require:
    - cmd: unzip_crm

{%- elif plugin.name == "wiki_extensions"%}

download_wiki_extensions:
  cmd.run:
  - name: wget https://bitbucket.org/haru_iida/redmine_wiki_extensions/downloads/redmine_wiki_extensions-0.6.4.zip
  - unless: "[ -f /root/redmine_wiki_extensions-0.6.4.zip ]"
  - cwd: /root
  - require:
    - cmd: install_redmine_{{ app.name }}

install_wiki_extensions:
  cmd.run:
  - name: unzip redmine_wiki_extensions-0.6.4.zip -d /srv/redmine/sites/{{ app.name }}/plugins/
  - unless: "[ -d /srv/redmine/sites/{{ app.name }}/plugins/redmine_wiki_extensions ]"
  - cwd: /root
  - require:
    - cmd: download_wiki_extensions

{%- elif plugin.name == "monitoring_controlling" %}

download_monitoring_controlling:
  cmd.run:
  - name: wget https://github.com/alexmonteiro/Redmine-Monitoring-Controlling/archive/v0.1.1.zip
  - unless: "[ -f /root/v0.1.1.zip ]"
  - cwd: /root
  - require:
    - cmd: install_redmine_{{ app.name }}

unzip_monitoring_controlling:
  cmd.run:
  - name: unzip v0.1.1.zip
  - unless: "[ -d /root/Redmine-Monitoring-Controlling-0.1.1 ]"
  - cwd: /root
  - require:
    - cmd: download_monitoring_controlling

/srv/redmine/sites/{{ app.name }}/plugins/Redmine-Monitoring-Controlling/init.rb:
  file:
  - managed
  - source: salt://redmine/conf/monitoring_controlling.rb
  - require:
    - cmd: move_monitoring_controlling

move_monitoring_controlling:
  cmd.run:
  - name: mv Redmine-Monitoring-Controlling-0.1.1 /srv/redmine/sites/{{ app.name }}/plugins/Redmine-Monitoring-Controlling
  - unless: "[ -d /srv/redmine/sites/{{ app.name }}/plugins/Redmine-Monitoring-Controlling ]"
  - cwd: /root
  - require:
    - cmd: unzip_monitoring_controlling

install_monitoring_controlling:
  cmd.run: 
  - name: cd /
  - cwd: /root
  - require:
    - cmd: move_monitoring_controlling
    - file: /srv/redmine/sites/{{ app.name }}/plugins/Redmine-Monitoring-Controlling/init.rb

{%- endif %}

{%- endfor %}

database_migration_{{ app.name }}:
  cmd.run:
    - name: rake redmine:plugins:migrate RAILS_ENV=production
    - cwd: /srv/redmine/sites/{{ app.name }}
    - require:
      {%- for plugin in app.plugins %}
      - cmd: install_{{ plugin.name }}
      {%- endfor %}

{%- endif %}

{%- if app.themes is defined %}
{%- for theme in app.themes %}
{%- if theme.name == 'coffee' %}

download_coffee:
  cmd.run:
  - name: wget http://redminecrm.com/license_manager/4508/coffee-0_0_3.zip
  - unless: "[ -f /root/coffee-0_0_3.zip ]"
  - cwd: /root  
  - require:
    - cmd: install_redmine_{{ app.name }}

unzip_coffee:
  cmd.run:
  - name: unzip coffee-0_0_3.zip -d /srv/redmine/sites/{{ app.name }}/public/themes/
  - unless: "[ -d /srv/redmine/sites/{{ app.name }}/public/themes/coffee ]"
  - cwd: /root
  - require:
    - cmd: download_coffee
{%- elif theme.name == 'highrise' %}

download_highrise:
  cmd.run:
  - name: wget http://redminecrm.com/license_manager/3918/highrise_tabs-1_1_1.zip
  - unless: "[ -f /root/highrise_tabs-1_1_1.zip ]"
  - cwd: /root  
  - require:
    - cmd: install_redmine_{{ app.name }}

unzip_highrise:
  cmd.run:
  - name: unzip highrise_tabs-1_1_1.zip -d /srv/redmine/sites/{{ app.name }}/public/themes/
  - unless: "[ -d /srv/redmine/sites/{{ app.name }}/public/themes/highrise_tabs ]"
  - cwd: /root
  - require:
    - cmd: download_highrise
{%- endif %}

{%- endfor %}
{%- endif %}

{%- endfor %}

{%- endif %}
