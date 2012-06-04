#!/usr/bin/env bash

echo "Crowdtap Environment Setup Script"

echo "Checking for SSH key, generating one if it doesn't exist ..."
  [[ -f ~/.ssh/id_rsa.pub ]] || ssh-keygen -t rsa

echo "Copying public key to clipboard. Paste it into your Github account ..."
  [[ -f ~/.ssh/id_rsa.pub ]] && cat ~/.ssh/id_rsa.pub | pbcopy
  open https://github.com/account/ssh

echo "Installing Homebrew, a good OS X package manager ..."
  /usr/bin/ruby -e "$(/usr/bin/curl -fsSL https://raw.github.com/mxcl/homebrew/master/Library/Contributions/install_homebrew.rb)"
  brew update

echo "Installing git, an extremely fast, efficient, distributed version control system ideal for the collaborative development of software."
  brew install git

echo "Installing mongodb, a scalable, high-performance, open source NoSQL database."
  brew install mongodb

echo "Installing Redis, a good key-value database ..."
  brew install redis

echo "Installing ack, a good way to search through files ..."
  brew install ack

echo "Installing tmux, a good way to save project state and switch between projects ..."
  brew install tmux

echo "Installing ImageMagick, good for cropping and re-sizing images ..."
  brew install imagemagick

echo "Installing QT, used by Capybara Webkit for headless Javascript integration testing ..."
  brew install qt

echo "Installing the Crowdtap Profile"
  cd ~ && git clone git@github.com:crowdtap/dotfiles.git .dotfiles
  cd ~/.dotfiles && make install

echo "Installing Oh My ZSH"
  curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh

echo "Put Homebrew location earlier in PATH ..."
  echo "
#recommended by brew doctor
export PATH='/usr/local/bin:$PATH'" >> ~/.zshrc
  source ~/.zshrc

echo "Installing RVM (Ruby Version Manager) ..."
  bash -s stable < <(curl -s -L https://get.rvm.io)
  echo "\n# RVM
[[ -s '/Users/`whoami`/.rvm/scripts/rvm' ]] && source '/Users/`whoami`/.rvm/scripts/rvm'" >> ~/.zshrc
  source ~/.zshrc

echo "Installing Ruby 1.9.2 stable and making it the default Ruby ..."
  rvm install 1.9.2-p290
  rvm use 1.9.2 --default

echo "Turning RVM trust rvmrc files on"
  echo "\n# Trust all rvmrc files
export rvm_trust_rvmrcs_flag=1" >> ~/.rvmrc

echo "Turning rDoc and riDoc off by default"
  touch ~/.gemrc
  echo "gem: --no-ri --no-rdoc\n" >> ~/.gemrc

echo "Installing bundler, a tool to manage an application's dependencies through its entire life across many machines systematically and repeatably."
  gem install bundler --no-rdoc --no-ri

echo "Creating a home for the apps"
  mkdir ~/code

echo "Checking out Crowdtap, the main app"
  cd ~/code
  git clone git@github.com:crowdtap/crowdtap.git

echo "Bundling Crowdtap"
  cd ~/code/crowdtap
  bundle

echo "Adding builder for Crowdtap"
  cd ~/code/crowdtap
  git remote add builder kareemk@ci.crowdtap.com:/Volumes/SSD/git-repos/crowdtap-builder.git

echo "Checking out Sniper, our targeting app"
  cd ~/code
  git clone git@github.com:crowdtap/sniper.git

echo "Bundling Sniper"
  cd ~/code/sniper
  bundle

echo "Updating Host file"
  WHOAMI="`whoami`" && sudo echo "

# Crowdtap
127.0.0.1          crowdtap.local
# Sniper
127.0.0.1          sniper.crowdtap.local" >> /etc/hosts

echo "Update Apache Virtual Host File"
  sudo touch /etc/apache2/other/crowdtap.vhost.conf
  WHOAMI="`whoami`" && sudo echo "
SetEnv PATH '/usr/local/bin/:$PATH'

<Directory '/Users/`echo $WHOAMI`/code/crowdtap/public'>
   Options FollowSymLinks
   AllowOverride None
   Order allow,deny
   Allow from all
</Directory>

NameVirtualHost *:80

<VirtualHost *:80>
  ServerName crowdtap.local
  DocumentRoot '/Users/`echo $WHOAMI`/code/crowdtap/public'
  RewriteCond %{DOCUMENT_ROOT}/%{REQUEST_FILENAME} !-f
  RewriteRule ^/(.*)$ http://127.0.0.1:3000%{REQUEST_URI} [P,QSA,L]
  ProxyPass / http://127.0.0.1:3000/
  ProxyPassReverse / http://127.0.0.1:3000/
</VirtualHost>

<VirtualHost *:80>
  ServerName sniper.crowdtap.local
  DocumentRoot '/Users/`echo $WHOAMI`/code/sniper/public'
  ProxyPass / http://127.0.0.1:3001/
  ProxyPassReverse / http://127.0.0.1:3001/
</VirtualHost>" >> /etc/apache2/other/crowdtap.vhost.conf

echo "Restarting Apache"
  sudo apachectl restart
