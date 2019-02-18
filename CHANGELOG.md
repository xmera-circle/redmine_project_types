Changelog for Project Types
===========================

0.2.5 *2019-02-18*
------------------

    Enabled Modules
    Custom Field Synchronization
    Project Types Default Modules
    Project Types Default Tracker

* [ADDED]: Adds form views/projects/settings/_modules.html.erb which overwrites
           the same view in Redmine Core. 
* [DELETED]: Deletes views/overrides/projects/settings since it is not working with
             <fieldset> HTML tag.
* [DELETED]:  Removes :issue_tracking module from enabled module list in project
              configurations.
* [MODIFIED]: Fixes projects custom field synchronization in tracker_patch.rb and 
              custom_field_patch.rb.
* [MODIEFIED]: Excludes saving enabled module names if checkboxes are set to disabled: true
               since in that case no params[:enabled_module_names] are submitted.
* [MODIFIED]: Fixes assignment of project types default module to projects with
              respective project types when saving model project_types_default_module.rb.
* [MODIFIED]: The same as above for default module but for trackers.
* [ADDED]:    Adds synchronization of custom fields in default trackers.


0.2.4 *2019-02-09*
------------------

    Plugin Settings

* [DELETED]: Deletes all plugin settings related code, files, dirs.


0.2.3 *2019-01-28*
------------------

		Labels
    Projects Modules
    Project Type Assignment
    Projects Modules, Trackers, Custom Fields
    Internationalisation

		
* [MODIFIED]: Modifies some labels.
*	[MODIFIED]: Changes readonly attribute for project modules into disabled.
* [ADDED]: Adds a HTML required tag to the drop down list for project types when creating a new
          project.
* [MODIFIED]: Fixes/refactors synchronisation in project modules, trackers, and custom fields.
* [MODIEFIED]: Adjusts all translations to project instead of object.



0.2.2 *2019-01-15*
------------------

		Redmine Main Menu
    Requirements
    Mitrations
    Copyright Year
    Projects Modules, Trackers, Custom Fields

		
* [MODIFIED]: Disables Redmine main menu when in admin area of project types.
* [MODIFIED]: Reworked some requirements of loading other files.
* [MODIFIED]: Modifies migration files migrating only if table not exists.
* [MODIFIED]: Adjusts copyright year to 2019.
* [MODIFIED]: Sets settings of module and tracker in project settings to read only and
              synchronizes the respective ids for the project based on project type.
* [MODIFIED]: Sets project mapping in custom field settings to read only and synchronizes
              the fields for the project based on the assigned trackers.


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
