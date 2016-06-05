#!/bin/sh

#install backdrop
sh $ZENCI_DEPLOY_DIR/scripts/backdrop_install.sh

echo "Full site path: $DOCROOT"

# Go to domain directory.
cd $DOCROOT


echo "Linking modules from $ZENCI_DEPLOY_DIR"

mkdir -p $DOCROOT/modules/contrib
mkdir -p $DOCROOT/themes/contrib
mkdir -p $DOCROOT/layouts/contrib

cd $DOCROOT/modules
ln -s $ZENCI_DEPLOY_DIR/modules ./custom

cd $DOCROOT/themes
ln -s $ZENCI_DEPLOY_DIR/themes ./custom

cd $DOCROOT/layouts
ln -s $ZENCI_DEPLOY_DIR/layouts ./custom


echo "Contrib modules"
sh $ZENCI_DEPLOY_DIR/scripts/contrib_modules.sh

echo "Contrib themes"
sh $ZENCI_DEPLOY_DIR/scripts/contrib_themes.sh

echo "Contrib layouts"
sh $ZENCI_DEPLOY_DIR/scripts/contrib_layouts.sh



echo "Enable Modules"

for module in `cat $ZENCI_DEPLOY_DIR/settings/modules.enable`; do
  php $ZENCI_DEPLOY_DIR/scripts/console.sh --root="$DOCROOT" --enable $module
done
