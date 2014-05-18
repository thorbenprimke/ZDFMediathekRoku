#########################################################################
# Simple makefile for packaging Roku Video Player example
#
# Makefile Usage:
# > make
# > make install
# > make remove
#
# Important Notes: 
# To use the "install" and "remove" targets to install your
# application directly from the shell, you must do the following:
#
# 1) Make sure that you have the curl command line executable in your path
# 2) Set the variable ROKU_DEV_TARGET in your environment to the IP 
#    address of your Roku box. (e.g. export ROKU_DEV_TARGET=192.168.1.90 and
#    export DEVPASSWORD=1122 to have both the box's address and password ready
#    for the makefile.
#    Set in your this variable in your shell startup (e.g. .bashrc)
##########################################################################  
APPNAME = ZDFMediathekRoku
VERSION = 1.0

ZIP_EXCLUDE= -x screenshots\* -x .git\* -x published\* -x artwork\* -x out\* -x dist\* -x \*.pkg -x .DS_Store -x .project -x .settings\* -x \*.md -x storeassets\* -x keys\* -x \*/.\*

include ../RokuSDK/examples/source/app.mk
