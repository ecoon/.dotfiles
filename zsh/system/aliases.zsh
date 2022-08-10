# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
if $(gls &>/dev/null)
then
  alias ls="gls -F --color -B"
  alias l="gls -lAh --color -B"
  alias ll="gls -l --color -B"
  alias la='gls -A --color -B'
fi
