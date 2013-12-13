# =============================================================================================
# To run this in Windows PowerShell do the following
# Visit https://github.com/dahlbyk/posh-git for instructions
# Clone the posh-git locally
# From the posh-git repository run .\install.ps1
# git clone git@github.com:dahlbyk/posh-git.git
# you can modify the default profile being loaded by posh-git by going to the cloned directory
# =============================================================================================


# START OF SCRIPT

# Clear and stop other PowerShell Instances
clear
echo "__________________________________________________________________"
echo "===> Stopping other PowerShell Instances"
Get-Process Powershell  | Where-Object { $_.ID -ne $pid } | Stop-Process

# Use URU to switch to the appropriate Ruby version and set working Variables
echo "__________________________________________________________________"
echo "===> Switching to Ruby 1.9.3 and configuring environment"
# Switch to Ruby 1.9.3 p 484
uru 193p484
# Set some working environment variables
$myEnvironment = "C:\Development\rails4stack\rails-windows"
$wiki = "C:\Development\rails4stack\rails-windows\rails-windows.github.io.wiki"
$fullsite = "C:\Development\rails4stack\rails-windows\rails-windows.github.io.wiki\_site\*"
$site = "C:\Development\rails4stack\rails-windows\rails-windows.github.io.wiki\_site"
$destination = "C:\Development\rails4stack\rails-windows\rails-windows.github.io"

# Perform some cleanup, if necessary
echo "__________________________________________________________________"
echo "===> Checking cleanup routines"
$_siteInWiki = Test-Path $site
if ($_siteInWiki){
  echo "===> Cleaning up.. Deleting io.wiki\_site"
  Remove-Item -Recurse -Force $site
} else {
  echo "===> Cleanup not necessary."
}

# Start the Gollum site generator
echo "__________________________________________________________________"
echo "===> Running Gollum-site generator in wiki"
cd $wiki
gollum-site generate
echo "... GENERATED _site";

# Copy _site to .io and overwrite all files
echo "__________________________________________________________________"
echo "===> Copying " $fullsite
echo "===> -TO-"
echo "===> Copying " $destination
Copy-Item $fullsite $destination -Recurse -Force

# Delete old _site directory in Wiki
echo "__________________________________________________________________"
echo "===> Deleting " $site
Remove-Item -Recurse -Force $site

# Push to Github.io.wiki
echo "__________________________________________________________________"
echo "===> COMMITTING to Github.io.wiki"
echo "_____________________USER INPUT REQUIRED!_________________________"
$commit = Read-Host 'Please type your commit message...'
git add -A
git commit -m $commit
git push origin master
echo "... FINISHED Pushing to github.io.wiki";

# Repush Home to Index
echo "__________________________________________________________________"
echo "===> Replace index.html with Home.html"
cd $destination
del index.html
move-item Home.html index.html

# Push to Github.io
echo "__________________________________________________________________"
echo "===> COMMITTING to Github.io"
git add -A
git commit -am $commit
git push origin master
echo "... FINISHED Pushing to github.io";
# END OF SCRIPT


# =============================================================================================
# Notes on getting this to work on Windows

# REDCLOTH gem 4.2.8

# Redcloth outputted a Use RBConfig insead of obsolete and deprecated config on redcloth.rb:10
# I had to use the following around line 10:

#conf = Object.const_get(defined?(RbConfig) ? :RbConfig : :Config)::CONFIG
#prefix = conf['arch'] =~ /mswin|mingw/ ? "#{conf['MAJOR']}.#{conf['MINOR']}/" : ''


# BLANKSLATE gem

# BlankSlate - I had to change the following around line 46 in blankslate-3.1.2\lib\blankslate.rb
# in order to supress warning level with warning on undefining object_id

#def hide(name)
#  # ADDED STATEMENT BELOW
#  v, $VERBOSE = $VERBOSE, nil
#  if instance_methods.include?(name._blankslate_as_name) and
#    name !~ /^(__|instance_eval$)/
#    @hidden_methods ||= {}
#    @hidden_methods[name.to_sym] = instance_method(name)
#    undef_method name
#  end
#  # ALSO ADDED STATEMENT BELOW
#   $VERBOSE = v
#end

# Golum site generate errors showed spawn can't convert nil into string
# grit 2.4.2 requires spawn-posix which does not work on windows
# I changed the gemspec in golum to show

# s.add_dependency('grit', "2.3.0") # which removes spawn-posix requirement

# I then installed grit 2.3.0 via
# gem build gollum.gemspec
# gem install gollum-1.4.3.gem

# After all 3 of these fixes, this now works on Windows
# =============================================================================================
