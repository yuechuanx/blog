#!/bin/bash

git submodule update --rebase --remote

# if failed
# rm -rf themes/meme
# git clone --depth 1 https://github.com/reuixiy/hugo-theme-meme.git themes/meme