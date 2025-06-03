#!/bin/sh -ex

doas sed -i 's/edge/v3.21/g' /etc/apk/repositories
doas apk upgrade -U --available
doas chown -R "$(id -u)" "$GITHUB_WORKSPACE"

[ -n "$RSA_PRIVATE_KEY" ] || {
  echo "RSA_PRIVATE_KEY is empty"
  exit 1
}
[ -n "$RSA_PUBLIC_KEY" ] || {
  echo "RSA_PUBLIC_KEY is empty"
  exit 1
}

echo "$RSA_PRIVATE_KEY" >"$GITHUB_WORKSPACE/$GITHUB_REPOSITORY_OWNER.rsa"
echo "$RSA_PUBLIC_KEY" >"$GITHUB_WORKSPACE/$GITHUB_REPOSITORY_OWNER.rsa.pub"
chmod 600 "$GITHUB_WORKSPACE/$GITHUB_REPOSITORY_OWNER.rsa"

export REPODEST="$GITHUB_WORKSPACE"
export PACKAGER="eNV25 <env252525@gmail.com>"
export PACKAGER_PRIVKEY="$GITHUB_WORKSPACE/$GITHUB_REPOSITORY_OWNER.rsa"

for pkgdir in "$GITHUB_WORKSPACE"/apkbuilds/repo/*; do
  if [ -f "$pkgdir"/APKBUILD ]; then
    echo "=== Building package in $pkgdir ==="
    cd "$pkgdir"
    abuild checksum
    abuild -r
    abuild clean
  fi
done

ls -la "$GITHUB_WORKSPACE/repo/x86_64/"
