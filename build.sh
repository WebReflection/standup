#!/usr/bin/env bash

set -euo pipefail

repo="https://github.com/WebReflection/standup"
site="https://webreflection.github.io/standup"

shopt -s nullglob
stories=([0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9].md)
IFS=$'\n' stories=($(printf '%s\n' "${stories[@]}" | sort))
unset IFS

title_from() {
  local title
  IFS= read -r title < "$1" || title="$1"
  title="${title#\# }"
  printf '%s' "$title"
}

html_escape() {
  local value="$1"
  value="${value//&/&amp;}"
  value="${value//</&lt;}"
  value="${value//>/&gt;}"
  value="${value//\"/&quot;}"
  printf '%s' "$value"
}

readme_intro() {
  cat <<EOF
# Andrea Giammarchi's Standup

Daily or weekly summaries around my current focus or things I am working on, a space for me to describe my journey as OSS employee / contributor.

[**GitHub** <sub><sup>📄</sup></sub>](${repo}) / [**Web** <sub><sup>🌍</sup></sub>](${site}/)

<sup>ℹ️ this is an experiment so far, but I am enjoying it already and I hope somebody, somewhere, one day will benefit from it 👋</sup>

- - -

EOF
}

readme_list() {
  local current_year="" current_month="" path year month day file i

  for ((i = ${#stories[@]} - 1; i >= 0; i--)); do
    path="${stories[$i]}"
    IFS=/ read -r year month file <<< "$path"
    day="${file%.md}"

    if [[ "$year" != "$current_year" ]]; then
      current_year="$year"
      current_month=""
      printf '  * %s\n' "$year"
    fi

    if [[ "$month" != "$current_month" ]]; then
      current_month="$month"
      printf '    * %s\n' "$month"
    fi

    printf '      * %s - [**GitHub** <sub><sup>📄</sup></sub>](%s/blob/main/%s) / [**Web** <sub><sup>🌍</sup></sub>](%s/%s/%s/%s.html)\n' "$day" "$repo" "$path" "$site" "$year" "$month" "$day"
  done
}

home_intro() {
  cat <<'EOF'
---
layout: home
title: Andrea Giammarchi's Standup
---

<section class="archive" aria-label="Story archive">
EOF
}

home_archive() {
  local current_year="" path year month day file title escaped_title i

  for ((i = ${#stories[@]} - 1; i >= 0; i--)); do
    path="${stories[$i]}"
    IFS=/ read -r year month file <<< "$path"
    day="${file%.md}"
    title="$(title_from "$path")"
    escaped_title="$(html_escape "$title")"

    if [[ "$year" != "$current_year" ]]; then
      current_year="$year"
      printf '  <h2 class="archive-year">%s</h2>\n' "$year"
    fi

    printf '  <article class="archive-card">\n'
    printf '    <time class="archive-date" datetime="%s-%s-%s">%s/%s</time>\n' "$year" "$month" "$day" "$month" "$day"
    printf '    <a class="archive-title" href='\''{{ %s | relative_url }}'\''>%s</a>\n' "\"/${year}/${month}/${day}.html\"" "$escaped_title"
    printf '    <a class="archive-source" href="%s/blob/main/%s">Source</a>\n' "$repo" "$path"
    printf '  </article>\n'
  done
}

home_footer() {
  cat <<'EOF'
</section>
EOF
}

story_data() {
  local path year month day file title

  for path in "${stories[@]}"; do
    IFS=/ read -r year month file <<< "$path"
    day="${file%.md}"
    title="$(title_from "$path")"

    printf -- '- path: %s\n' "$path"
    printf '  url: /%s/%s/%s.html\n' "$year" "$month" "$day"
    printf '  date: %s-%s-%s\n' "$year" "$month" "$day"
    printf '  title: >-\n'
    printf '    %s\n' "$title"
  done
}

{
  readme_intro
  readme_list
  printf '\n- - -\n'
} > README.md

{
  home_intro
  home_archive
  home_footer
} > index.md

story_data > _data/stories.yml
