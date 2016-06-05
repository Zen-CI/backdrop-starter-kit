#!/bin/sh

GITHUBDIR="$HOME/github"
TARGETFOLDER="$DOCROOT/layouts/contrib"

for layout in `cat $ZENCI_DEPLOY_DIR/settings/contrib_layouts.list`; do
  owner=`echo $layout|awk -F/ '{print$1}'`
  repo=`echo $layout|awk -F/ '{print$2}'`
  branch=`echo $layout|awk -F/ '{print$3}'`

  LAYOUT_DEPLOY_DIR="$GITHUBDIR/$owner/$repo/$branch"
  
  if [ -d "$LAYOUT_DEPLOY_DIR" ]; then
    echo "UPDATE $owner/$repo"
    cd $LAYOUT_DEPLOY_DIR
    git pull
    if [ "$branch" != "" ]; then
      git checkout $branch
    fi
  else
    echo "DOWNLOAD $owner/$repo"
    mkdir -p $LAYOUT_DEPLOY_DIR
    cd $LAYOUT_DEPLOY_DIR
    git clone -q https://github.com/$owner/$repo.git .
    if [ "$branch" != "" ]; then
      git checkout $branch
    fi
    cd $TARGETFOLDER
    ln -s $LAYOUT_DEPLOY_DIR ./$repo
  fi
  
done
