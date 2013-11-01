## [Redmine](http://www.redmine.org/) project management

Redmine is a flexible project management web application. Written using the Ruby on Rails framework, it is cross-platform and cross-database.
Redmine is open source and released under the terms of the GNU General Public License v2 (GPL).

* Multiple projects support
* Flexible role based access control
* Flexible issue tracking system
* Gantt chart and calendar
* News, documents & files management
* Feeds & email notifications
* Per project wiki
* Per project forums
* Time tracking
* Custom fields for issues, time-entries, projects and users
* SCM integration (SVN, CVS, Git, Mercurial, Bazaar and Darcs)
* Issue creation via email
* Multiple LDAP authentication support
* User self-registration support
* Multilanguage support
* Multiple databases support
***
### Support

* requires: 

 * [Ruby](../master/ruby)
 * [PostgreSQL](../master/postgresql), [MySQL](../master/mysql), mssql
* service versions: 2.3
* operating systems: Ubuntu 12.04
***
#### Plugins 

* [CRM](http://www.redminecrm.com/projects/crm/pages/1)
* [Theme-changer](http://www.redmine.org/issues/4602)
* [Wiki-template](http://www.redmine.org/plugins/gsc_templates)
* [Wiki-extensions](http://www.r-labs.org/projects/r-labs/wiki/Wiki_Extensions_en)

##### Working

* [Redmine-Monitoring-Controlling](http://alexmonteiro.github.io/Redmine-Monitoring-Controlling) - without translate !TODO

***
#### Themes

* [Coffee](http://redminecrm.com/pages/coffee-theme)
* [Highrise](http://redminecrm.com/pages/highrise-theme)

### Basic pillar

    redmine:
      enabled: true
      version: '2.3'
      apps:
      - name: majklk
        database:
          engine: postgresql
          host: 127.0.0.1
          name: db_name
          password: pass
          user: user_name
        mail:
          host: host-mail
          password: pass
          user: email
          domain: domain

### Sample pillar with plugins and themes with mssql server conection

    redmine:
      enabled: true
      version: '2.3'
      apps:
      - name: majklk
        database:
          engine: sqlserver
          dataserver: data_server `nullable`
          host: 127.0.0.1
          name: db_name
          password: pass
          user: user_name
        mail:
          host: host-mail
          password: pass
          user: email
          domain: domain
        plugins:
        - name: crm
        - name: wiki_extensions
        - name: `monitoring_controlling`
        - name: theme_changer
        - name: wiki_template
        themes:
        - name: coffee
        - name: highrise

`be sure with apostrophes`

### Read more

* http://www.redmine.org/
* http://www.redmine.org/projects/redmine/wiki/RedmineInstall
