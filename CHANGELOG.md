# Changelog for Redmine Project Types

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## unreleased

## Deleted

* ActiveRecord Callbacks from patches
## 2.0.0 - 2021-02-07

### Changed

* all ProjectType model associations and its tables
* ProjectType views to be more consistend with Redmine

### Added

* further tests

## 1.0.2 - 2021-01-29

### Changed

* ProjectType related stuff of the ProjectsControllerPatch to be in a
separate module

## 1.0.1 - 2021-01-26

### Added

* Redmine core test patch for modified custom field and project settings view
* description column in project types table

### Changed

* some views in order to disable tracker, module, custom field, and projects
where it is expected to modify them in project types admin area
* icon size of project types admin menu
* table columns to be as much as column headlines in project types table

### Deleted

* ProjectsControllerPatch#modules patch

## 1.0.0 - 2021-01-08

### Added

* support for Redmine 4.1.1

### Changed

* plugin id to redmine_project_types
* copyright

0.3.0 *2019-04-23*
------------------

    Custom Field Synchronization
    Show Projects
    Module List
    Gemfile
    Test Fixtures
    Redmine 3.4.10 Support.

* [MODIFIED]: Fixes bug in ...

0.2.6 *2019-04-23*
------------------

    Custom Field Synchronization
    Show Projects
    Module List
    Gemfile
    Test Fixtures
    Redmine 3.4.10 Support.

* [MODIFIED]: Fixes bug in ProjectTypesDefaultTracker#sync_project_custom_fields 
              occuring when there are projects and project types but no assignment between them.
* [MODIFIED]: Considers projects having no project type assigned so that no nil error occurs
              when trying to show the project.
* [MODIFIED]: Modifies module list which is displayed in project configuration to show always :roadmap
              but :tickets only if plugin :issue_cloning is not installed.
* [ADDED]:    Adds Gemfile with gem deface.
* [MODIFIED]: Extends test fixtures.


0.2.5 *2019-02-18*
------------------

    Enabled Modules
    Custom Field Synchronization
    Project Types Default Modules
    Project Types Default Tracker

* [ADDED]: Adds form views/projects/settings/_modules.html.erb which overwrites the same view in Redmine Core.
* [DELETED]: Deletes views/overrides/projects/settings since it is not working with `<fieldset>` HTML tag.
* [DELETED]:  Removes :issue_tracking module from enabled module list in project configurations.
* [MODIFIED]: Fixes projects custom field synchronization in tracker_patch.rb and custom_field_patch.rb.
* [MODIEFIED]: Excludes saving enabled module names if checkboxes are set to disabled: true since in that case no params[:enabled_module_names] are submitted.
* [MODIFIED]: Fixes assignment of project types default module to projects with respective project types when saving model project_types_default_module.rb.
* [MODIFIED]: The same as above for default module but for trackers.
* [ADDED]: Adds synchronization of custom fields in default trackers.


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
* [MODIFIED]: Changes readonly attribute for project modules into disabled.
* [ADDED]: Adds a HTML required tag to the drop down list for project types when creating a new project.
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
* [MODIFIED]: Sets settings of module and tracker in project settings to read only and synchronizes the respective ids for the project based on project type.
* [MODIFIED]: Sets project mapping in custom field settings to read only and synchronizes the fields for the project based on the assigned trackers.

0.2.1 *2018-12-01*
------------------

	Redmine 3.4.6 Support
	Redmine DMSF 1.6.1 Support
	Depreciation of alias_method_chain in Rails 5.1
	Object Creation
		
* [FIXED]: Disables enabled module names and tracker if project types plugin is enabled and a new object should be created.
* [FIXED]: Fixes intersection with Redmine DMSF version 1.6.1. See #157.
* [MODIFIED]: Changes patching method from alias_method_chain to prepend.

0.2.0 *2018-01-30*
------------------

    Code Refactoring
    Licence Text
    Markdown Files
    Project View Modification with Deface
    Redmine 3.4.4 Support
    
* [MODIFIED]: adjusts folders and files to meet a better structure for patching redmine core
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
