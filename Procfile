web: puma -b unix:$(pwd)/var/web.sock
sshd: rake sshd:exec
nginx: $(which nginx) -c $(pwd)/config/nginx.conf
