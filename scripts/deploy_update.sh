#!/bin/sh


echo "Full site path: $DOCROOT"

# Go to domain directory.
cd $DOCROOT

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
