# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4;-*-

# Copyright (c) 2023 Sebastian Gniazdowski

# Exit code, 0 by default
integer EC

# Parse any options given to this preamble.inc.zsh file
local -A Opts
builtin zparseopts \
    ${${(M)ZSH_VERSION:#(5.[8-9]|6.[0-9])}:+-F} \
        -D -E -A Opts -- -func||return 7

# Set options
((!$+Opts[--func]))&&builtin emulate -L zsh -o extendedglob \
                        -o warncreateglobal -o typesetsilent \
                        -o noshortloops -o nopromptsubst

integer QIDX=${@[(i)(--|-)]}
((QIDX<=$#))&&builtin set -- "$@[1,QIDX-1]" "$@[QIDX+1,-1]"
# Set $0 with a new trik - use of %x prompt expansion
0=${${(M)${0::=${(%):-%x}}:#/*}:-$PWD/$0}

# Unset helper function on exit
builtin trap 'unset -f iqmsg_subst iqmsg_cmd_helper&>>$ZIQLOG;
        unset -f -m tmp/\* &>>$ZIQLOG' EXIT

# Standard hash `Plugins` for plugins, to not pollute the namespace
# ZIQ is a hash for iqmsg color theme and for the body of all aliases
typeset -gA Plugins ZIQ
Plugins[ANGEL_SYSTEM_DIR]="${0:h:h}"
export ZIQDIR="${0:h:h}" \
       ZIQAES="${0:h:h}"/aliases \
       ZIQLOG="${0:h:h}"/io.log \
       IQNICK=${IQNICK:-Angel-IQ} \
       ZIQNUL=/dev/null

# Standard work variables
typeset -g -a reply match mbegin mend
typeset -g REPLY MATCH; integer MBEGIN MEND

# fpath extending for a plugin.zsh sourcing
if [[ $+Opts[--func] == 0 &&
    ${zsh_loaded_plugins[-1]} != */zsh-iq-system &&
    -z ${fpath[(r)$ZIQDIR]}
]];then
    fpath+=("$ZIQDIR" "$ZIQDIR/functions")
fi

# fpath-localizing for from-func sourcing
(($+ZINIT&&!$+Opts[--func]))&&local -Ua fpath_save=($fpath)
(($+Opts[--func]))&&\
    local -Ua fpath=($ZIQDIR/{,bin,functions,libexec} $fpath) \
                path=($ZIQDIR/{,bin,functions,libexec} $path)
fpath[1,0]=($ZIQDIR/{,bin,functions,libexec})

# Autoload via fpath, not direct paths
autoload -z $ZIQDIR/functions/*~*~(.N:t) \
            $ZIQDIR/functions/*/*~*~(.N:t2) \
            $ZIQDIR/bin/*~*~(.N:t) \
            regexp-replace #zsweep:pass

# Set up aliases
iq::setup-aliases||\
    {print -P Couldn\'t set up aliases, some %F{27}Zsh IQ%f\
        components might not work…
    EC=1;}

int/iq::reset

# Restore fpath if it's ZINIT sourcing, it saves fpath internally
(($+fpath_save))&&fpath=($fpath_save)

return EC