# Zsh IQ System

A bunch of intelligent extensions to Zsh. Features:

1. Smart console – a TUI application allowing to run configure & make
   and open editor on exact locations of reported errors.
2. In-shell Ctags browser – list all symbols in `TAGS` index created
   with Universal Ctags and open editor on their source locations.
3. IQ Swiss Knife – a utility allowing:
   - quick Ctags generation,
   - variable contents dumping.
4. A set of global aliases in the form `NAME…STR` allowing clever
   tests of variable contents. The strings are:
   - `EMPTYSTR` – `[:space:][:INCOMPLETE:][:INVALID:]$'\e']#` – any
     number of spaces, incomplete chars or invalid chars –
     essentially an empty string,
   - `INVALIDSTR` – `*[[:INCOMPLETE:][:INVALID:]]*` – a string
     holding at least one invalid character,
   - `EMORINSTR` – empty or invalid string,
   - `FUNCSTR` – a string of the form: `abc() {…` with all possible
     variants (like e.g.: preceding `function` keyword),
   - `IDSTR` – a string with all characters allowed in Zsh variable
     name,
   - `PRINTSTR` – a string with all characters being printable,
   - `WRONGSTR` – a string either empty, invalid, control-chars only,
     zeroes-only or non-printable only,
   - `ZEROSTR` – a string with only `0` character,
   - `CTRLSTR` – a string consisting of only control characters.

To use the global alias do:
```zsh
if [[ $var == WRONGSTR ]]; then
…
fi
```

## Build console

A TUI frontend to `configure` and `make`. Its main feature is
opening `$EDITOR` on exact position of an error or warning in its
source file.

![iqcon](https://raw.githubusercontent.com/psprint/zsh-iq-system/master/share/img/iqcon.png)

