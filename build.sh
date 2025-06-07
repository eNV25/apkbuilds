#!/bin/sh -eu

doas chown -v -R "$(id -u)" "$GITHUB_WORKSPACE"
echo "$RSA_PRIVATE_KEY" >"$GITHUB_WORKSPACE/$GITHUB_REPOSITORY_OWNER.rsa"
echo "$RSA_PUBLIC_KEY" >"$GITHUB_WORKSPACE/$GITHUB_REPOSITORY_OWNER.rsa.pub"

set -x

cat <<-'EOF' | doas tee /etc/apk/repositories
https://dl-cdn.alpinelinux.org/alpine/v3.21/main
https://dl-cdn.alpinelinux.org/alpine/v3.21/community
EOF
doas apk upgrade -U --available
doas apk add github-cli

chmod -v 600 "$GITHUB_WORKSPACE/$GITHUB_REPOSITORY_OWNER.rsa"
doas cp -v "$GITHUB_WORKSPACE/$GITHUB_REPOSITORY_OWNER.rsa.pub" /etc/apk/keys/

export REPODEST="$GITHUB_WORKSPACE"
export PACKAGER="eNV25 <env252525@gmail.com>"
export PACKAGER_PRIVKEY="$GITHUB_WORKSPACE/$GITHUB_REPOSITORY_OWNER.rsa"

for pkg in "$GITHUB_WORKSPACE"/apkbuilds/repo/*; do
  if [ -f "$pkg"/APKBUILD ]; then
    abuild -C "$pkg" fetch verify
  fi
done

mkdir -p "$REPODEST"/repo/x86_64/
gh release download x86_64 -R "$GITHUB_REPOSITORY" -D "$REPODEST"/repo/x86_64/ --clobber -p APKINDEX.tar.gz -p '*.apk'

for pkg in "$GITHUB_WORKSPACE"/apkbuilds/repo/*; do
  if [ -f "$pkg"/APKBUILD ]; then
    abuild -C "$pkg" -r all clean
  fi
done

abuild cleanoldpkg

ls -la "$GITHUB_WORKSPACE/repo/x86_64/"
