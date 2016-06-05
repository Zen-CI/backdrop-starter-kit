#!/bin/sh

GITHUBDIR="$HOME/github"
TARGETFOLDER="$DOCROOT/themes/contrib"

for module in `cat $ZENCI_DEPLOY_DIR/settings/contrib_themes.list`; do
  owner=`echo $module|awk -F/ '{print$1}'`
  repo=`echo $module|awk -F/ '{print$2}'`
  branch=`echo $module|awk -F/ '{print$3}'`

  THEME_DEPLOY_DIR="$GITHUBDIR/$owner/$repo/$branch"
  
  if [ -d "$THEME_DEPLOY_DIR" ]; then
    echo "UPDATE $owner/$repo"
    cd $THEME_DEPLOY_DIR
    git pull
    if [ "$branch" != "" ]; then
      git checkout $branch
    fi
  else
    echo "DOWNLOAD $owner/$repo"
    mkdir -p $THEME_DEPLOY_DIR
    cd $THEME_DEPLOY_DIR
    git clone -q https://github.com/$owner/$repo.git .
    if [ "$branch" != "" ]; then
      git checkout $branch
    fi
    cd $TARGETFOLDER
    ln -s $THEME_DEPLOY_DIR ./$repo
  fi
done
