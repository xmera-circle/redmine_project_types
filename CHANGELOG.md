Changelog for Project Types
===========================

0.2.2 *2019-01-03*
------------------

		Redmine Main Menu
    Requirements
		
* [MODIFIED]: Disables Redmine main menu when in admin area of project types.
* [MODIFIED]: Reworked some requirements of loading other files.


0.2.1 *2018-12-01*
------------------

		Redmine 3.4.6 Support
		Redmine DMSF 1.6.1 Support
		Depreciation of alias_method_chain in Rails 5.1
		Object Creation
		
* [FIXED]: Disables enabled module names and tracker if project types plugin is
					 enabled and a new object should be created.
* [FIXED]: Fixes intersection with Redmine DMSF version 1.6.1. See #157.
* [MODIFIED]: Changes patching method from alias_method_chain to prepend.

0.2.0 *2018-01-30*
------------------

    Code Refactoring
    Licence Text
    Markdown Files
    Project View Modification with Deface
    Redmine 3.4.4 Support
    
* [MODIFIED]: adjusts folders and files to meet a better structure
              for patching redmine core
* [ADDED]: adds the licence text to all relevant files
* [MODIFIED]: adjusts the CHANGELOG and README to .md-files
* [ADDED]: uses deface to place a call hook into the project view


0.1.4 *2017-12-03*
------------------

    Label Renaming
    
* [MODIFIED]: labels from Objekt-Typ adjusted to Objekttyp

0.1.3 *2017-11-26*
------------------

    Requirements
    
* [MODIFIED]: requires redmine 3.3.2 or higher

0.1.2 *2017-11-23*
------------------

    Plugin Display 
    Main Menu Deactivation
    
* [ADDED]: adds html options to menu methods in order to display the icon correctly
* [MODIFIED]: deactivates the main menu with self.main_menu = false in the corresponding controller
* [MODIFIED]: main_menu deactivation is commented out for running the plugin in redmine version 3.3.2
 
0.1.1 *2017-05-01*
------------------

    Label Renaming
    
* [MODIFIED]: renames all project related labels to object

0.1.0 *2017-04-28*
------------------

    Initial Version
