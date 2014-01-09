web: puma -b unix:$(pwd)/var/web.sock
sshd: $(which sshd) -D -e -f $(pwd)/var/config/sshd.conf
nginx: $(which nginx) -c $(pwd)/var/config/nginx.conf
