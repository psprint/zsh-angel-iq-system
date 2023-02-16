# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4;-*-

# Copyright (c) 2023 Sebastian Gniazdowski

# According to the Zsh Plugin Standard:
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard

0=${${(M)${0::=${(%):-%x}}:#/*}:-$PWD/$0}

# Read the common setup code, to create the $ZIQ*… vars and aliases, etc.
source $0:h/share/preamble.inc.zsh

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

() {
    local IQTMP
    # Alt-a for plugin IDs and Alt-c for ices are default.
    zstyle -s ":iq:action-complete:plugin-id" key IQTMP||IQTMP='\ea'
    [[ -n $IQTMP ]]&&bindkey $IQTMP iq::action-complete
    zstyle -s ":iq:action-complete:ice" key IQTMP||IQTMP='\ec'
    [[ -n $IQTMP ]]&&bindkey $IQTMP iq::action-complete-ice
}

[[ ! -f $ZPFX/config.site ]]&&command cp -vf $ZIQDIR/share/config.site $ZPFX
[[ $PKG_CONFIG_PATH != (|*:)$ZPFX(|*[:/]*) ]]&&PKG_CONFIG_PATH="$ZPFX/lib/pkgconfig:$PKG_CONFIG_PATH"
[[ $CMAKE_PREFIX_PATH != (|*:)$ZPFX(|*[:/]*) ]]&&CMAKE_PREFIX_PATH="$ZPFX:$CMAKE_PREFIX_PATH"
[[ $LD_LIBRARY_PATH != (|*:)$ZPFX(|*[:/]*) ]]&&LD_LIBRARY_PATH="$ZPFX/lib:$LD_LIBRARY_PATH"

# vim:ft=zsh:tw=80:sw=4:sts=4:et:foldmarker=[[[,]]]
