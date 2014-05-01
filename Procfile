# -- web: the web service ---------------------------------------------

web:            bundle exec thin start --socket `pwd`/var/web.sock -e production
nginx:          $(which nginx) -c `pwd`/var/config/nginx.conf
checker:        bundle exec rake run:check

# -- sshd: the sshd listener and port forwarder -----------------------

sshd:           $(which sshd) -D -e -f `pwd`/var/config/sshd.conf

# -- metric_system ----------------------------------------------------

metric_system:   bundle exec script/metric_system

# -- fnordmetric ------------------------------------------------------

# redis:          redis-server var/config/redis.conf
# fnordmetric:    bundle exec ruby config/fnordmetric.rb
