web:            sleep 0.2 && bundle exec thin start --socket `pwd`/var/web.sock
checker:        sleep 0.2 && rake run:check
sshd:           sleep 0.2 && $(which sshd) -D -e -f `pwd`/var/config/sshd.conf
nginx:          sleep 0.2 && $(which nginx) -c `pwd`/var/config/nginx.conf

redis:          redis-server var/config/redis.conf
