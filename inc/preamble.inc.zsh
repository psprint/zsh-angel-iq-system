#!/usr/bin/env zsh
 
builtin emulate -L zsh
builtin setopt extendedglob kshglob warncreateglobal typesetsilent \
                noshortloops rcquotes noautopushd

# Possibly fix $0 with a new trick – use of a %x prompt expansion
0="${${(M)${0::=${(%):-%x}}:#/*}:-$PWD/$0}"

export ZIQDIR ZIQCMDS ZIQFUNCS ZIQAES ZIQLOG
# Restore the variables if needed (i.e. not exported)
: ${ZIQDIR:=$0:h:h} \
        ${ZIQCMDS=::$0:h:h/bin} \
        ${ZIQFUNCS=::$0:h:h/functions} \
        ${ZIQAES=::$0:h:h/aliases} \
        ${ZIQLOG:=$(mktemp)}

# Unset helper function on exit
builtin trap 'unset -f iqmsg_subst iqmsg_cmd_helper &>$ZIQLOG' EXIT

# Mute possible create global warning
typeset -ag match mbegin mend reply
typeset -g MATCH REPLY; integer -g MBEGIN MEND

iq::clean() {
    # Cleanup
    REPLY= MATCH= MBEGIN= MEND= reply=() match=() mbegin=() mend=()
}

iq::clean

# Load any case both files and symlinks (@ and .)
builtin autoload -z regex-replace "$ZIQFUNCS"/*[^~](N.,@)
