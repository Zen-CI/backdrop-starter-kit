#!/bin/sh

BACKDROP_DEPLOY="$HOME/github/backdrop/docs"
BACKDROP_GIT_REPO="https://github.com/itpatrol/backdrop.git"
BACKDROP_BRANCH="docs"

echo "Installing backdrop to " . $DOCROOT

if [ -d "$BACKDROP_DEPLOY" ]; then
  cd $BACKDROP_DEPLOY
  git pull
else
  mkdir -p $BACKDROP_DEPLOY
  cd $BACKDROP_DEPLOY
  git clone -q $BACKDROP_GIT_REPO .
  git checkout $BACKDROP_BRANCH
fi


# Go to domain directory.
cd $DOCROOT

# Link Backdrop files
ln -s $BACKDROP_DEPLOY/* ./
ln -s $BACKDROP_DEPLOY/.htaccess ./

# Unlink settings.php and copy instead.
rm -f settings.php
cp $BACKDROP_DEPLOY/settings.php ./

# Unlink files and copy instead.
rm -f files
cp -r $BACKDROP_DEPLOY/files ./

# Unlink sites and copy instead.
rm -f sites
cp -r $BACKDROP_DEPLOY/sites ./

# Unlink modules and copy instead.
rm -f modules
cp -r $BACKDROP_DEPLOY/modules ./

# Unlink themes and copy instead.
rm -f themes
cp -r $BACKDROP_DEPLOY/themes ./

# Install Backdrop.
php $DOCROOT/core/scripts/install.sh --account-mail=$ACCOUNT_MAIL --account-name=$ACCOUNT_USER --account-pass="$ACCOUNT_PASS" --site-mail=$SITE_MAIL --site-name="$SITE_NAME" --db-url=mysql://$DATABASE_USER:$DATABASE_PASS@localhost/$DATABASE_NAME --root=$DOCROOT

echo "user: $ACCOUNT_USER pass: $ACCOUNT_PASS"