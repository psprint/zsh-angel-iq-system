# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4;-*-

# Copyright (c) 2023 Sebastian Gniazdowski

integer EC=0

# According to the Zsh Plugin Standard:
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard
0=${ZERO:-${${${(M)${0::=${(%):-%x}}:#/*}:-$PWD/$0}:A}}
# Spread a simulated ZERO support over every plugin utils
local ZERO=$0

# Create dummy pattern aliases (eq to *) to detect lack of disk ones
() {for REPLY ($0:h/aliases/str/*[A-Z](N.:t)){alias -g $REPLY='*'};}

# Read the common setup code, to create the $ZIQ*… vars and aliases, etc.
source $0:h/share/preamble.inc.zsh --script
EC+=$?

alias apo="noglob \\angel open"

# Ctags symbol browser
zle -N iq::browse-symbol
zle -N iq::browse-symbol-backwards iq::browse-symbol
zle -N iq::browse-symbol-pbackwards iq::browse-symbol
zle -N iq::browse-symbol-pforwards iq::browse-symbol
() {
    local IQTMP
    zstyle -s ':iq:browse-symbol' key IQTMP||IQTMP='\ew'
    [[ -n $IQTMP ]]&&bindkey $IQTMP iq::browse-symbol
}

# A custom completion of plugin ids (alt-a) and of ice names (alt-c)
zle -N iq::action-complete
zle -N iq::action-complete-ice iq::action-complete
(){
    local IQTMP
    # Alt-a for plugin IDs and Alt-c for ices are default.
    zstyle -s ":iq:action-complete:plugin-id" key IQTMP||IQTMP='\ea'
    [[ -n $IQTMP ]]&&bindkey $IQTMP iq::action-complete
    zstyle -s ":iq:action-complete:ice" key IQTMP||IQTMP='\ec'
    [[ -n $IQTMP ]]&&bindkey $IQTMP iq::action-complete-ice
}

() {
    export TINFO
    [[ $TINFO == $~galiases[WRONGSTR] ]]&&\
        TINFO=${XDG_CONFIG_HOME:-$HOME/.config}/tigsuite/features.reg
    if [[ ! -d $TINFO:h ]];then
        builtin print -P -- $IQHD ${(%)ZIQ[Q7_NO_TINFO_DIR_EXISTS]}
    elif [[ ! -f $TINFO ]];then
        {builtin print -n >$TINFO;}||\
        {EC+=$?;print -P -- $IQHD ${(%)ZIQ[Q4_NO_TINFO_CANT_CREATE]};}
    fi
}
return EC
# vim:ft=zsh:tw=80:sw=4:sts=4:et:foldmarker=[[[,]]]