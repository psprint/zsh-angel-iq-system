# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4;-*-

# Copyright (c) 2023 Sebastian Gniazdowski

# Exit code, 0 by default
integer EC

# Parse any options given to this preamble.inc.zsh file
local -A Opts
builtin zparseopts \
    ${${(M)ZSH_VERSION:#(5.[8-9]|6.[0-9])}:+-F} \
        -D -E -A Opts -- -fun -script||return 18

# Set options
(($+Opts[--fun]))&&builtin emulate -L zsh \
                        -o extendedglob \
                        -o warncreateglobal -o typesetsilent \
                        -o noshortloops -o nopromptsubst \
                        -o rcquotes

integer QIDX=${@[(i)(--|-)]}
((QIDX<=$#))&&builtin set -- "$@[1,QIDX-1]" "$@[QIDX+1,-1]"
# Set $0 with a new trik - use of %x prompt expansion
0=${${(M)${0::=${(%):-%x}}:#/*}:-$PWD/$0}

# Unset helper function on exit
builtin trap 'unset -f -m tmp/\* &>>$ZIQLOG' EXIT

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

# fpath-saving for main script sourcing
if (($+ZINIT&&!$+Opts[--fun]))&&\
    [[ $ZERO == */zsh-angel-iq-system.plugin.zsh ]]
then
    local -Ua fpath_save=($fpath)
fi

# fpath extending for a plugin.zsh sourcing
if ((!$+Opts[--fun]))&&\
        [[ $ZERO != */zsh-angel-iq-system.plugin.zsh &&\
            -z ${fpath[(r)$ZIQDIR]} ]]
then
    fpath+=("$ZIQDIR" "$ZIQDIR/functions")
fi

# Localize path and fpath for procedures
if (($+Opts[--fun]));then
    local -Uxa fpath=($ZIQDIR/{bin,functions,libexec} $fpath) \
                path=($ZIQDIR/{bin,functions,libexec} $path)
fi

# Unconditionally extend path for either plugin source or
# a func. Will be reverted when sourcing from Zinit (it
# saves the fpath new dirs at autoload command)
fpath[1,0]=($ZIQDIR/{bin,functions,libexec})

# Uniquify paths
typeset -gU fpath FPATH path PATH

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