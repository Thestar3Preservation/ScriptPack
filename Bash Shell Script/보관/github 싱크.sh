#!/bin/bash

VERSION=$(<version)

#git init
#git remote add origin https://github.com/Thestars3/arkzip.git
git rm --cached -r .
git add .
git commit -m v$VERSION
git push
# git push origin +master


#최초 생성시
# git init
# git add .
# git remote add origin https://github.com/Thestars3/libunhv3.git
# git push -u origin master
