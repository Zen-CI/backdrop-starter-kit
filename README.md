# backdrop-startup-kit
Repository contain integration scripts to start using deploy via ZenCI for BackdropCMS website

It has next structure
-------
```yaml
layouts					#put your own custom layouts here
modules					#put your own custom modules here
scripts					#deploy related scripts
  backdrop_install.sh	#download via git Backdrop code and prepare DOCROOT
  console.sh			#script to enable modules
  contrib_layouts.sh	#download and update contrib layouts
  contrib_modules.sh	#download and update contrib modules
  contrib_themes.sh		#download and update contrib themes
  deploy_init.sh		#init script. It will be executed only if {deploy_dir} is empty
  deploy_update.sh		#after script. It will be executed after each push to repository
settings				#meta data for deploy
  contrib_layouts.list	#list of layouts
  contrib_modules.list	#list of modules
  contrib_themes.list	#list of themes
  modules.enable		#list of modules to enable
themes					#put your own custom themes here
```

**contrib\_%.list** files has next structure:
repository_owner/repository_name/branch

- repository_owner - usually is backdrop-contrib, but if you have your own fork of layout, theme or module, you can put your login
- repository_name - name of the project. 
- branch - this one is optional. If not provided, master or main brach will be selected.

contrib_layouts.list example:
```bash
backdrop-contrib/radix_layouts
backdrop-contrib/juiced_up_layouts
```

contrib_modules.list example:
```bash
backdrop-contrib/altpager
backdrop-contrib/parsedown_filter
backdrop-contrib/devel
```

contrib_themes.list example:
```bash
backdrop-contrib/bootstrap_lite
backdrop-contrib/news_arrow
```

**deploy_init.sh** will create directory structure in $HOME/github 
-------

```yaml
github:
  backdrop:
    backdrop:				#backdrop get cloned here
  YOURNAME:
    backdrop-startup-kit:	#your repository get cloned here
      modules: 				# your own modules
      themes: 				# your own themes
      layouts: 				# your own layouts
  backdrop-contrib:
    module_example:			# here is a clone of contrib module_example
    theme_example:			# here is a clone of contrib theme_example
    layout_example:			# here is a clone of contrib layout_example
```

Your **DOCROOT** will have next structure:

```textile
core -> ~/github/backdrop/backdrop/core
files
.htaccess
index.php -> ~/github/backdrop/backdrop/index.php
layouts
modules
profiles -> ~/github/backdrop/backdrop/profiles
README.md -> ~/github/backdrop/backdrop/README.md
robots.txt -> ~/github/backdrop/backdrop/robots.txt
settings.php
sites
themes
```

Credits
-------

- [BackdropCMS](https://backdropcms.org)
- [HowTO](http://docs.zen.ci/getting-started/advanced-deploy-backdrop)


License
-------

This project is GPL v2 software. See the LICENSE.txt file in this directory for
complete text.
