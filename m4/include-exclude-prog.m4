#serial 1
dnl Copyright (C) 2007 Free Software Foundation, Inc.
dnl This file is free software; the Free Software Foundation
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.

dnl From Jim Meyering.

# Usage: gl_ADD_PROG([prog_list_var_name], [prog_name])
AC_DEFUN([gl_ADD_PROG],
[{
  $1="$$1 $2"
  MAN="$MAN $2.1"
}])

# Usage: gl_REMOVE_PROG([prog_list_var_name], [prog_name])
AC_DEFUN([gl_REMOVE_PROG],
[{
  $1=`echo "$$1"|sed 's/\<'"$1"'//;s/  */ /g'`
  MAN=`echo "$MAN"|sed 's/\<'"$1"'\.1//'`
}])

# Given the name of a variable containing a space-separated list of
# install-by-default programs and the list of do-not-install-by-default
# programs, modify the former variable to reflect "don't-install" and
# "do-install" requests.
#
# Usage: gl_INCLUDE_EXCLUDE_PROG([prog_list_var_name], [NI_prog1])
AC_DEFUN([gl_INCLUDE_EXCLUDE_PROG],
[{
  gl_no_install_progs_default=$2
  AC_ARG_ENABLE([install-program],
    [AS_HELP_STRING([--enable-install-program=PROG_LIST],
		    [install the programs in PROG_LIST (comma-separated,
		    default: none)])],
    [gl_do_install_prog=$enableval],
    [gl_do_install_prog=]
  )

  # If you want to refrain from installing programs A and B,
  # use --enable-no-install-program=A,B
  AC_ARG_ENABLE([no-install-program],
    [AS_HELP_STRING([--enable-no-install-program=PROG_LIST],
		    [do NOT install the programs in PROG_LIST (comma-separated,
		    default: $gl_no_install_progs_default)])],
    [gl_no_install_prog=$enableval],
    [gl_no_install_prog=]
  )

  # For each not-to-be-installed program name, ensure that it's a
  # valid name, remove it from the list of programs to build/install,
  # as well as from the list of man pages to install.
  extra_programs=
  for gl_i in `echo "$gl_no_install_prog"|tr -s , ' '`; do

    # Fail upon a request to install and not-install the same program.
    case ",$gl_do_install_prog," in
      *",$gl_i,"*) AC_MSG_ERROR(['$gl_i' is both included and excluded]) ;;
    esac

    gl_msg=
    # Warn about a request not to install a program that is not being
    # built (which may be because the systems lacks a required interface).
    case " $$1 " in
      *" $gl_i "*) gl_REMOVE_PROG([$1], $gl_i) ;;
      *) gl_msg="'$gl_i' is already not being installed" ;;
    esac

    if test "$gl_msg" = ''; then
      # Warn about a request not to install a program that is
      # already on the default-no-install list.
      case " $gl_no_install_progs_default " in
	*" $gl_i "*) gl_msg="by default, '$gl_i' is not installed" ;;
      esac
    fi

    test "$gl_msg" != '' && AC_MSG_WARN([$gl_msg])
  done

  for gl_i in `echo "$gl_do_install_prog"|tr -s , ' '`; do
    case " $gl_no_install_progs_default " in
      *" $gl_i "*) gl_ADD_PROG([$1], $gl_i) ;;
      *) AC_MSG_WARN(['$gl_i' is not an optionally-installable program]) ;;
    esac
  done
}])