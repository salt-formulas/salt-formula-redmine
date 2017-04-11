
===============
Redmine Formula
===============

Redmine is a flexible project management web application. Written using the Ruby on Rails framework, it is cross-platform and cross-database.


Sample pillars
==============

.. code-block:: yaml

    redmine:
      server:
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

More Information
================

* http://www.redmine.org/
* http://www.redmine.org/projects/redmine/wiki/RedmineInstall
