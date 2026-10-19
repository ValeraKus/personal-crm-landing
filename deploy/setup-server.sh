#!/usr/bin/env bash
# One-time server setup for landing deploys, run as root: setup-server.sh "<public SSH key of GitHub Actions>"
# The server is shared with the app, so it only adds our own things:
# the landing user, /var/www/context-crm.site and the nginx site of the landing. Safe to run again.
set -euo pipefail
cd "$(dirname "$0")"

deploy_key=${1:?usage: setup-server.sh \"<public SSH key of GitHub Actions>\"}
site_dir=/var/www/context-crm.site
site=context-crm.site.conf

# landing: the user GitHub Actions logs in as. No sudo, no docker
id landing > /dev/null 2>&1 || useradd --create-home --shell /bin/bash landing

# The key can only upload files into the landing folder with rsync (rrsync -wo):
# no shell, no reading files back, nothing outside the folder
key_line="command=\"/usr/bin/rrsync -wo $site_dir\",restrict $deploy_key"
install -d -o landing -g landing -m 700 /home/landing/.ssh
keys=/home/landing/.ssh/authorized_keys
touch "$keys"
grep -qxF "$key_line" "$keys" || echo "$key_line" >> "$keys"
chown landing:landing "$keys"
chmod 600 "$keys"

install -d -o landing -g landing -m 755 "$site_dir"
# Until the first deploy the folder shows the same placeholder as before, not an error
if [ -z "$(ls -A "$site_dir")" ] && [ -f /var/www/placeholder/index.html ]; then
  install -o landing -g landing -m 644 /var/www/placeholder/index.html "$site_dir/index.html"
fi

# nginx: the landing domain serves the landing folder instead of the placeholder
target=/etc/nginx/sites-available/$site
if ! cmp -s "nginx/$site" "$target"; then
  backup=""
  if [ -f "$target" ]; then
    backup=$target.bak-$(date +%Y%m%d-%H%M%S)
    cp "$target" "$backup"
  fi
  install -m 644 "nginx/$site" "$target"
  ln -sf "../sites-available/$site" "/etc/nginx/sites-enabled/$site"
  if ! nginx -t; then
    [ -n "$backup" ] && cp "$backup" "$target"
    echo "nginx config test failed: the previous config is restored" >&2
    exit 1
  fi
  systemctl reload nginx
  echo "nginx: $site installed${backup:+, the previous version saved to $backup}"
fi

echo "Server is ready for landing deploys"
