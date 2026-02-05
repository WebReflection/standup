#!/usr/bin/env bash

intro() {
  echo "# Andrea Giammarchi Standup

Daily or weekly summaries around my current focus or things I am working on, a space for me to describe my journey as OSS employee / contributor.

[**GitHub** <sub><sup>📄</sup></sub>](https://github.com/WebReflection/standup) / [**Web** <sub><sup>🌍</sup></sub>](https://webreflection.github.io/standup/)

<sup>ℹ️ this is an experiment so far, but I am enjoying it already and I hope somebody, somewhere, one day will benefit from it 👋</sup>

- - -
"
}

list() {
  for y in $(ls); do
    if [ -d "$y" ]; then
      cd $y
      echo "  * $y"
      for m in $(ls); do
        if [ -d "$m" ]; then
          cd $m
          echo "    * $m"
          for f in $(ls *.md); do
            echo "      * ${f:0:-3} - [**GitHub** <sub><sup>📄</sup></sub>](https://github.com/WebReflection/standup/blob/main/${y}/${m}/${f}) / [**Web** <sub><sup>🌍</sup></sub>](https://webreflection.github.io/standup/${y}/${m}/${f:0:-3}.html)"
          done
          cd ..
        fi
      done
      cd ..
    fi
  done
}

intro > README.md
list >> README.md
echo "
- - -" >> README.md
