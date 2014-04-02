web:            bundle exec thin start --socket `pwd`/var/web.sock
checker:        rake run:check
sshd:           $(which sshd) -D -e -f `pwd`/var/config/sshd.conf
nginx:          $(which nginx) -c `pwd`/var/config/nginx.conf
