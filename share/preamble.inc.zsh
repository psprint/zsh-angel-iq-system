#!/usr/bin/env zsh
# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4;-*-

# Copyright (c) 2023 Sebastian Gniazdowski

# Exit code, assign 0 by default (no silent option yet)
integer EC=0

# Parse any options given to this preamble.inc.zsh file
local -A Opts=()
builtin zparseopts \
    ${${(M)ZSH_VERSION:#(5.[8-9]|6.[0-9])}:+-F} \
        -D -E -A Opts -- -fun -script -cleanup||return 18

# Set options
(($+Opts[--fun]))&&builtin emulate -L zsh \
                        -o extendedglob \
                        -o warncreateglobal -o typesetsilent \
                        -o noshortloops -o nopromptsubst \
                        -o rcquotes

integer QIDX=${@[(i)(--|-)]}
((QIDX<=$#))&&builtin set -- "$@[1,QIDX-1]" "$@[QIDX+1,-1]"
# Set $0 with a new trik - use of %x prompt expansion
0=${${${(M)${0::=${(%):-%x}}:#/*}:-$PWD/$0}:A}

zmodload zsh/terminfo zsh/termcap zsh/system zsh/datetime
local QC
(($+Opts[--cleanup]))&&QC="print -n $terminfo[rmcup]$termcap[te]"
# Unset helper function on exit
(($+Opts[--fun]))&&builtin trap 'builtin unset -f -m tmp/\*&>>|$ZIQNUL;
            builtin unset IQHD&>>|$ZIQNUL;'$QC EXIT

EC+=$?

# Standard hash `Plugins` for plugins, to not pollute the namespace
# ZIQ is a hash for iqmsg color theme and for the body of all aliases
typeset -gA Plugins ZIQ
Plugins[ANGEL_IQ_SYSTEM_DIR]="${0:h:h}"
export ZIQDIR="${0:h:h}" \
       ZIQAES="${0:h:h}"/aliases \
       ZIQLOG="${0:h:h}"/io.log \
       IQNICK=${IQNICK:-Angel-IQ} \
       ZIQTXT="${0:h:h}/share/txt" \
       ZIQCFG="${XDG_CONFIG_HOME:-$HOME/.config/angel}/angel.cfg" \
       \
       ZIQNUL=/dev/null \
       ZIQDBG=/tmp/reply

[[ ! -f $ZIQCFG ]]&&\
    {command mkdir -p -- $ZIQCFG:h;cp -vf -- "$ZIQDIR/angel.cfg" "$ZIQCFG";}

# Standard work variables
typeset -g -a reply match mbegin mend
typeset -g REPLY MATCH; integer MBEGIN MEND

# fpath-saving for main script sourcing
if (($+ZINIT&&!$+Opts[--fun]))&&\
    [[ $ZERO == */zsh-angel-iq-system.plugin.zsh ]]
then
    local -Ua fpath_save=($fpath)
fi

# fpath extending for a plugin.zsh sourcing
if ((!$+Opts[--fun]&&!fpath[(I)$ZIQDIR]))&&\
        [[ $ZERO != */zsh-angel-iq-system.plugin.zsh ]]
then
    fpath+=("$ZIQDIR" "$ZIQDIR/functions")
fi

# Localize path and fpath for procedures
if (($+Opts[--fun]));then
    local -Uxa fpath=($ZIQDIR/{bin,functions,libexec} $fpath) \
                path=($ZIQDIR/{bin,functions,libexec} $path)
elif [[ $ZERO == */zsh-angel-iq-system.plugin.zsh ]];then
    # Unconditionally extend path for plugin source
    fpath[1,0]=($ZIQDIR/{bin,functions,libexec})
fi

# Uniquify paths
typeset -gU fpath FPATH path PATH

# Autoload via fpath, not direct paths
autoload -z $ZIQDIR/functions/*~*~(.N:t) \
            $ZIQDIR/functions/*/*~(*~|*/ok/qlocal)(.N:t2) \
            $ZIQDIR/bin/*~*~(.N:t) \
            throw catch #zsweep:pass

builtin autoload +zX ok/qlocal

#
# Simple, small support messaging system
#

# Header with (%)-expansion
ZIQ[head-txt]="%F{41}%B[%b$IQNICK%B]"\
"%F{27}[%b\${\${(%):-%x}:t}:\${(%):-%I}%B]%b: %B%F{203}Error:%b"
local IQHD=$ZIQ[head-txt]

#
# Remaining tasks: aliases and vars reset
#
# Set up aliases
if ! iq::setup-aliases;then
    EC+=$?
    builtin print -P -- $IQHD ${(%)ZIQ[Q1_ALIASES_NOT_SETUP]}
fi

# Test autoload by resetting work vars
if ! int/iq::reset;then
    EC=EC+$?
    builtin print -P -- $IQHD ${(%)ZIQ[Q3_AUTOLOAD_NOT_CORRECT]}
fi

#
# Cleanup:
#

## - Restore fpath if it's ZINIT sourcing, it saves fpath internally
(($+fpath_save))&&fpath=($fpath_save)

## Return EC value
return EC
