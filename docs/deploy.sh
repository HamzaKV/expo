#!/usr/bin/env bash

set -euo pipefail

aws s3 sync out s3://docs.expo.io --delete

aws s3 cp \
  --recursive \
  --metadata-directive REPLACE \
  --cache-control "public,max-age=31536000,immutable" \
  s3://docs.expo.io/_next/static/ \
  s3://docs.expo.io/_next/static/

declare -A redirects

# usage:
# redicts[requests/for/this/path]=are/redirected/to/this/one

# Temporarily create a redirect for a page that Home links to
redirects[versions/latest/introduction/installation.html]=versions/latest/introduction/installation/
# useful link on twitter
redirects[versions/latest/guides/app-stores.html]=versions/latest/distribution/app-stores/

for i in "${!redirects[@]}
do
  aws s3 cp \
    --metadata-directive REPLACE \
    --website-redirect "/${redirects[$i]}" \
    out/404.html \
    "s3://docs.expo.io/$i"
done
