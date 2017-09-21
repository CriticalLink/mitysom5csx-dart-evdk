# Basler demo_app configure AC script
#
# Developed for Basler by Critical Link LLC
# C. 2017 Critical Link LLC
#

# Must have AC_INIT (package, version, bug-report-address
AC_INIT([demo_app], [1.0], [support@criticallink.com])

# Runs many macros required for proper operation of the generated Makefiles
AM_INIT_AUTOMAKE([-Wall -Werror foreign])

AC_ARG_ENABLE(debug,
AS_HELP_STRING([--enable-debug],
               [enable debugging, default: no]),
[case "${enableval}" in
             yes) debug=true ;;
             no)  debug=false ;;
             *)   AC_MSG_ERROR([bad value ${enableval} for --enable-debug]) ;;
esac],
[debug=false])

AM_CONDITIONAL(DEBUG, test x"$debug" = x"true")

# We need a C++ compiler
AC_PROG_CXX

# put config options in config.h
AC_CONFIG_HEADERS([config.h])
# Configure these files
AC_CONFIG_FILES([
 Makefile
 src/Makefile
])

# Mandatory AC_OUTPUT
AC_OUTPUT

