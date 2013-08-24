sudo su vagrant && \
source ~/.profile && \
rbenv shell 2.0.0-p247 && \
gem install bundler && \
cd /vagrant && \
bundle install --verbose && \

rake db:create && \
rake db:schema:load && \
rake db:test:prepare