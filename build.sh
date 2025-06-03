#!/bin/sh -ex

sed -i 's/edge/v3.21/g' /etc/apk/repositories
apk upgrade -U --available

WORKSPACE="${GITHUB_WORKSPACE:-/github/workspace}"
echo "Using workspace: $WORKSPACE"

[ -n "$RSA_PRIVATE_KEY" ] || {
  echo "RSA_PRIVATE_KEY is empty"
  exit 1
}
[ -n "$RSA_PUBLIC_KEY" ] || {
  echo "RSA_PUBLIC_KEY is empty"
  exit 1
}

echo "$RSA_PRIVATE_KEY" >"$WORKSPACE/$GITHUB_REPOSITORY_OWNER.rsa"
echo "$RSA_PUBLIC_KEY" >"$WORKSPACE/$GITHUB_REPOSITORY_OWNER.rsa.pub"
chmod 600 "$WORKSPACE/$GITHUB_REPOSITORY_OWNER.rsa"

export REPODEST="$WORKSPACE"
export PACKAGER="eNV25 <env252525@gmail.com>"
export PACKAGER_PRIVKEY="$WORKSPACE/$GITHUB_REPOSITORY_OWNER.rsa"

for pkgdir in "$WORKSPACE"/apkbuilds/repo/*; do
  if [ -f "$pkgdir"/APKBUILD ]; then
    echo "=== Building package in $pkgdir ==="
    cd "$pkgdir"
    abuild checksum
    abuild -r
    abuild clean
  fi
done

ls -la "$WORKSPACE/repo/x86_64/"
