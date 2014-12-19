#!/bin/bash

# fix java.lang.NoClassDefFoundError: Could not initialize class sun.awt.X11GraphicsEnvironment 
export JAVA_OPTS="${JAVA_OPTS} -Djava.awt.headless=true"

# set ghost4j env
#export JAVA_OPTS="${JAVA_OPTS} -Djna.library.path=/home/webuser/Downloads/ghostscript-9.14-linux-x86"
