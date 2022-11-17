
needed_x=(
  base-devel libX11-devel libXft-devel
  libXinerama-devel freetype-devel fontconfig-devel
  git curl imlib2
  imlib2-devel xorg-fonts kitty
  dmenu vim mesa-dri libglvnd
  meson cmake libev-devel
)

git_sources_defaults=(
  https://github.com/kavulox/dwm
  https://github.com/kavulox/dwmblocks
)

repodir=/tmp/repo

curl ifconfig.me
sleep 10
snip() {
  echo "$1" | rev | cut -d "/" -f1 | rev
}

_make_install() {
  git clone "$1" "$repodir/$(snip $1)"

}

# ensure repodir exists (/tmp/repo)
if [ -d "$repodir" ]; then
  rm -rf "$repodir"
fi

if [ ! -d "$repodir" ]; then
  mkdir "$repodir"
fi
# Run updates for xbps & system
sudo xbps-install -Suy
sudo xbps-install -u xbps --yes
read -r -n 1 -p $'\nConfigure using defaults? NO (n) YES (y) ~> ' defaults
if [ "$defaults" = "y" ]; then
  echo -e "This script will deploy a simple DWM config from kavulox."
  mkdir ~/.vconf
  echo -e "Using directory at /tmp/repo"
  sleep 1
  for i in "${needed_x[@]}"; do
    echo -e "Installing package: $i"
    sudo xbps-install "$i" --yes
  done
  for i in "${git_sources_defaults[@]}"; do
    echo -e "Cloning repo: $i"
    git clone "$i" "$repodir/$(snip $i)"
    cd "$repodir/$(snip $i)" || return
    sudo make install
  done
fi
# Cleanup!
read -r -n 1 -p $'\nBackup important configuration directories to ~/.config ? NO (n) YES (y) ~> ' backup
if [ "$defaults" = "y" ]; then
  cp -rf "$repodir/dwm" "$HOME/.config/"
fi

read -r -n 1 -p $'\nConfigure pulseaudio? NO (n) YES (y) ~> ' _pulse
if [ "$_pulse" = "y" ]; then
  if [[ "$(sudo sv status /var/service/*)" =~ "dbus" ]]; then
    sudo xbps-install -S pulseaudio
  else
    sudo ln -s /etc/sv/dbus /var/service/
    sudo sv start dbus
    sudo xbps-install -S pulseaudio
    read -r -n 1 -p $'\nConfigure bluetooth? NO (n) YES (y) ~> ' _bluetooth
    if [ "$_bluetooth" = "y" ]; then
      sudo xbps-install -S bluez
      sudo ln -s /etc/sv/bluetoothd /var/service
      sudo sv start start bluetoothd
    fi
  fi
fi




# Continuations
read -r -n 1 -p $'\nThe full installation of software is complete, and we would like to offer the chance to install some extra homebrewed tools :) YES (y) DONE (d) ~> ' _cont
if [ "$_cont" = "y" ]; then
  echo $'\n'
  mkdir ~/.zsh
  read -r -n 1 -p $'\nInstall ArtixLabs deer zsh package manager? YES (y) NO (n) ~> ' _container
  if [ "$_container" = "y" ]; then
    echo $'\n'
    git clone https://github.com/ArtixLabs/deer "$repodir/deer"
    cp "$repodir/deer/deer.zsh" ~/.zsh
    echo "source ~/.zsh/deer.zsh" >> ~/.zshrc
  fi
  read -r -n 1 -p $'\nInstall kavulox kavpass? YES (y) NO (n) ~> ' _container
  if [ "$_container" = "y" ]; then
    echo $'\n'
    git clone https://github.com/kavulox/kavpass "$repodir/kavpass"
    cd "$repodir/kavpass" || return
    make
    sudo make install
  fi
  read -r -n 1 -p $'\nInstall kavulox neovim configuration? YES (y) NO (n) ~> ' _container
  if [ "$_container" = "y" ]; then
    echo $'\n'
    git clone https://github.com/ArtixLabs/deer "$HOME/.config/nvim"
  fi
  read -r -n 1 -p $'\nInstall ArtixLabs deer zsh package manager? YES (y) NO (n) ~> ' _container
  if [ "$_container" = "y" ]; then
    echo $'\n'
    git clone https://github.com/ArtixLabs/deer "$repodir/deer"
    cp "$repodir/deer/deer.zsh" ~/.zsh
    echo "source ~/.zsh/deer.zsh" >> ~/.zshrc
  fi
fi


rm -rf "$repodir"
