# Notes on building a new OSX machine

## fix system defaults
* system->trackpad, scroll direction not natural
* system->keyboard
  * shortcuts -> mission control
    * applications windows --> control+option+down
    * move left/right space to control+option+left/right
    * mission control to control+option+up
* system->Dock->auto hide and show the dock


## clone and install dotfiles
* `git clone https://github.com/ecoon/.dotfiles ~/.dotfiles`
* `cd ~/.dotfiles`
* `script/bootstrap`

## install from ORNL managed software
* corkscrew
* xcode
* xquartz
* commvault


## install from dmg/pkg/appstore
* [iterm2](https://iterm2.com/downloads.html)
  * NOTE: can we export profiles to dotfiles?
  * add color scheme solarized-zenburn from dotfiles
  * enable shell_integration: iterm2 menu --> install shell integration
  * enable hotkey window: window menu?
  * L/R option sends Esc+

## keyboard 

* reprogram kinesis keyboard if needed:
  * Progrm + shift + F10 resets memory
  * Progrm + |/ turns of the stupid click
  * = + m makes it mac mode (now control keys send command, left alt sends option, right alt sends control)
  * Progrm + F12 turns on remap mode
    * page up, end  (makes end a page up)
    * lcontrol, home (makes home a command)
    * lcontrol, page up (makes page up a command)
    * lalt, ralt (makes ralt an alt)
    * ralt, lctrl (makes lctrl a ctrl)
    * ralt, rctrl (makes rctrl a ctrl)
    * Progrm + F12 turns off remap mode


## install zsh and plugins
* install zsh:  `chsh -s /bin/zsh`
* install oh-my-zsh: `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
* install powerline10k: `git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k`  (Note p10k.zsh included in dotfiles)
* install autosuggestions: `git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions`


* download and install dotfiles: `git clone https://github.com/ecoon/.dotfiles ~/.dotfiles && cd ~/.dotfiles && scripts/bootstrap`  (Note this installs homebrew, overwrites .zshrc)

## install homebrew things
* `brew install coreutils findutils gnu-sed gnu-tar gnu-which gnutls grep gzip wget gpg htop astyle aspell --lang=en gcc openmpi cmake hub`
* `brew cask install emacs`  NOTE: may have to relink emacs from .dotfiles?
* `brew install lmod` NOTE: lmod init is sourced in modules.zsh

## set up code
* `mkdir /Users/Shared/ornldev/code/`
* `ln -s /Users/Shared/ornldev/code ~/code`

## anaconda
* download [mamba](https://github.com/conda-forge/miniforge#mambaforge)
* `conda install numpy matplotlib scipy ipython jupyter h5py` in the base env

## set up ATS code
* `cd ~/code`
* `git clone ecoon ats_manager` (assuming hub is working now)
* `python ats_manager/bin/install_amanzi.py --mpi=openmpi/4.0.5 --bootstrap-options='--with-fort-flags="-fallow-argument-mismatch" --with-c-flags="-Wno-error-implicit-function-declaration"' master `

