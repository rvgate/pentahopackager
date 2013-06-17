#!/bin/sh 
PACKAGE_NAME="lswpentaho"
PACKAGE_VERSION="1.0"

PACKAGE_FULLNAME="${PACKAGE_NAME}-${PACKAGE_VERSION}"

# Fetch additional settings
SCRIPTPATH=`pwd`
PACKAGE_ROOT="$SCRIPTPATH/$PACKAGE_FULLNAME"
RESOURCES="$SCRIPTPATH/resources"


# ==========================================================
# REMOVE OLD PACKAGE
#rm "${PACKAGE_FULLNAME}.deb"
rm "$PACKAGE_ROOT" -Rf
# ==========================================================

# ==========================================================
# DOWNLOAD PENTAHO
#wget http://downloads.sourceforge.net/project/pentaho/Business%20Intelligence%20Server/4.8.0-stable/biserver-ce-4.8.0-stable.tar.gz
#wget http://downloads.sourceforge.net/project/pentaho/Data%20Integration/4.4.0-stable/pdi-ce-4.4.0-stable.tar.gz
#tar -xvf biserver-ce-4.8.0-stable.tar.gz
#tar -xvf pdi-ce-4.4.0-stable.tar.gz
# ==========================================================


# ==========================================================
# PREPARING FOLDERS
# ==========================================================
mkdir "$PACKAGE_ROOT" -p
echo "Copying biserver-ce"
mkdir "$PACKAGE_ROOT/opt/pentaho/biserver-ce/" -p
cp "$SCRIPTPATH/biserver-ce/" "$PACKAGE_ROOT/opt/pentaho/" -Rf

echo "Copying administration-console"
mkdir "$PACKAGE_ROOT/opt/pentaho/administration-console/" -p
cp "$SCRIPTPATH/administration-console/" "$PACKAGE_ROOT/opt/pentaho/" -Rf

echo "Copying data-integration"
mkdir "$PACKAGE_ROOT/opt/pentaho/data-integration/" -p
cp "$SCRIPTPATH/data-integration/" "$PACKAGE_ROOT/opt/pentaho/" -Rf

echo "Adding upstart script"
mkdir "$PACKAGE_ROOT/etc/init" -p
cp "$RESOURCES/upstart/pentaho.conf" "$PACKAGE_ROOT/etc/init/"
# ==========================================================

# ==========================================================
# APPLY PATCHES
# ==========================================================
# Apply patches for biserver-ce
cd "$PACKAGE_ROOT/opt/pentaho/biserver-ce/"
git apply "$RESOURCES/patches/biserver-ce/0001-Copied-MySQL-driver-from-administration-console.patch"
git apply "$RESOURCES/patches/biserver-ce/0002-Converted-to-MySQL.patch"
git apply "$RESOURCES/patches/biserver-ce/0003-Disabled-Hypersonic-automatic-startup.patch"
git apply "$RESOURCES/patches/biserver-ce/0004-Converted-Quartz-to-MySQL.patch"
git apply "$RESOURCES/patches/biserver-ce/0005-Disabled-evaluation-login.patch"
git apply "$RESOURCES/patches/biserver-ce/0006-Disabled-HSQL-startup-listener.patch"
git apply "$RESOURCES/patches/biserver-ce/0007-Added-original-config-files.patch"
git apply "$RESOURCES/patches/biserver-ce/0008-Added-initial-repository-and-quartz-databases.patch"
git apply "$RESOURCES/patches/biserver-ce/0009-Removed-global-department-session-startup-action.patch"

# Apply patches for administration-console
cd "$PACKAGE_ROOT/opt/pentaho/administration-console/"
git apply "$RESOURCES/patches/administration-console/0001-Added-original-config-files.patch"

# Apply patches for data-integration
cd "$PACKAGE_ROOT/opt/pentaho/data-integration/"
git apply "$RESOURCES/patches/data-integration/0001-Added-mysql-library-from-administration-console.patch"

exit
# ==========================================================


# ==========================================================
# CREATING PACKAGE
# ==========================================================
# Add debian packaging files
echo "Adding debian package files"
mkdir "$PACKAGE_ROOT/DEBIAN" -p
cp "$RESOURCES/DEBIAN/control" "$PACKAGE_ROOT/DEBIAN/"
cp "$RESOURCES/DEBIAN/config" "$PACKAGE_ROOT/DEBIAN/"
cp "$RESOURCES/DEBIAN/postinst" "$PACKAGE_ROOT/DEBIAN/"
cp "$RESOURCES/DEBIAN/postrm" "$PACKAGE_ROOT/DEBIAN/"
cp "$RESOURCES/DEBIAN/templates" "$PACKAGE_ROOT/DEBIAN/"
chmod 0775 "$PACKAGE_ROOT/DEBIAN/postinst"
chmod 0775 "$PACKAGE_ROOT/DEBIAN/postrm"
chmod 0775 "$PACKAGE_ROOT/DEBIAN/config"
# ==========================================================

# ==========================================================
# BUILD DEBIAN PACKAGE
# ==========================================================
cd "$PACKAGE_ROOT/../"
exit
dpkg-deb --build "$PACKAGE_ROOT"
# ==========================================================
