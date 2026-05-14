#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

./build.sh

if command -v gem >/dev/null 2>&1; then
  gem_bin="$(gem env user_gemhome)/bin"
  if [ -d "$gem_bin" ]; then
    PATH="$gem_bin:$PATH"
  fi
fi

if command -v jekyll >/dev/null 2>&1; then
  unset BUNDLE_BIN_PATH BUNDLE_GEMFILE BUNDLE_PATH BUNDLE_USER_HOME
  export JEKYLL_NO_BUNDLER_REQUIRE=true
  exec jekyll serve --livereload
fi

if [ -f Gemfile ] && command -v bundle >/dev/null 2>&1; then
  export BUNDLE_USER_HOME="${BUNDLE_USER_HOME:-$PWD/.bundle}"
  export BUNDLE_PATH="${BUNDLE_PATH:-$PWD/.bundle/gems}"
  bundle check >/dev/null 2>&1 || bundle install
  exec bundle exec jekyll serve --livereload
fi

cat >&2 <<'EOF'
Jekyll is not installed.

On Arch Linux, install Ruby and Bundler with:

  sudo pacman -S ruby base-devel
  gem install --user-install bundler

Then make sure Ruby's user gem bin directory is in your PATH and run:

  ./preview.sh

The local site will be available at:

  http://127.0.0.1:4000/standup/
EOF

exit 1
