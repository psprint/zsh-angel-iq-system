# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4;-*-

# Copyright (c) 2023 Sebastian Gniazdowski

# According to the Zsh Plugin Standard:
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard

0=${${(M)${0::=${(%):-%x}}:#/*}:-$PWD/$0}

# Read the common setup code, to create the $ZIQ*… vars and aliases, etc.
source $0:h/share/preamble.inc.zsh

zle -N iq::browse-symbol
zle -N iq::browse-symbol-backwards iq::browse-symbol
zle -N iq::browse-symbol-pbackwards iq::browse-symbol
zle -N iq::browse-symbol-pforwards iq::browse-symbol

() {
    local IQTMP
    zstyle -s ':iq:browse-symbol' key IQTMP || IQTMP='\eQ'
    [[ -n $IQTMP ]] && bindkey $IQTMP iq::browse-symbol
}

# vim:ft=zsh:tw=80:sw=4:sts=4:et:foldmarker=[[[,]]]
