if [ -f .veewee_params ]
then
  . .veewee_params
fi
# Install Ruby from packages
apt-get -y install ruby ruby-dev libopenssl-ruby1.8 irb ri rdoc

if [ "$PURE" == "yes" ]; then
  apt-get -y install rubygems
else
  # Install Rubygems from source
  rg_ver=1.8.22
  curl -o /tmp/rubygems-${rg_ver}.zip \
    "http://production.cf.rubygems.org/rubygems/rubygems-${rg_ver}.zip"
  (cd /tmp && unzip rubygems-${rg_ver}.zip && \
    cd rubygems-${rg_ver} && ruby setup.rb --no-format-executable)
  rm -rf /tmp/rubygems-${rg_ver} /tmp/rubygems-${rg_ver}.zip
fi
