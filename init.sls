
include:
{%- if pillar.redmine.server is defined %}
- redmine.server
{%- endif %}