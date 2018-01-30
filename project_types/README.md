Project Types Plugin
====================

The current version of Project Types Plugin is **0.2.0**.

Project Types is a plugin for xmera:isms based on Redmine. It allows to define individual project types.

Initial development was for xmera e.K. and it is released as open source.
Project home: <http://#>

Project Types Plugin is distributed under GNU General Public License v2 (GPL).  
Redmine is a flexible project management web application, released under the terms of the GNU General Public License v2 (GPL) at <http://www.redmine.org/>

Further information about the GPL license can be found at
<http://www.gnu.org/licenses/old-licenses/gpl-2.0.html#SEC1>

Features
--------

* Create individual project types with default settings
* Assign each new project to a project type and get 
  its default settings automatically 


Dependencies
------------

  
  * Redmine 3.3.2 or higher
  * gem deface

Usage
-----

1. Go to admin menu -> object types -> new object type
1. Create an object type with all its default settings
1. When creating a new object choose the object type 



Setup / Upgrade
---------------

Before installing ensure that the Redmine instance is stopped.

1. Put project_types plugin directory into plugins.
1. Run a migration with: `RAILS_ENV=production rake redmine:plugins:migrate NAME=project_types`
1. Restart the web server.

Uninstalling DMSF Modifications
-------------------------------

Before uninstalling the Project Types Plugin, please ensure that the Redmine instance is stopped.

1. `cd [redmine-install-dir]`
1. ``RAILS_ENV=production rake redmine:plugins:migrate VERSION= 0 NAME=project_types`
1. `rm plugins/project_types -Rf`

After these steps re-start your instance of Redmine.

Contributing
------------

If you've added something, why not share it. Fork the repository (github.com/#), 
make the changes and send a pull request to the maintainers.

Changes with tests, and full documentation are preferred.

Additional Documentation
------------------------

[CHANGELOG.md](CHANGELOG.md) - Project changelog