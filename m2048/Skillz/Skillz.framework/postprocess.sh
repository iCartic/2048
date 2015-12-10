#!/bin/sh -x
PATH=/usr/libexec:$PATH

echo "Running Skillz SDK post processing script"

#Add Plist value to properly inform user of Location Request for iOS 8
if ! PlistBuddy -c 'Print NSLocationWhenInUseUsageDescription' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}";
then
   PlistBuddy -c 'Add :NSLocationWhenInUseUsageDescription string "Due to legal requirements we require your location in games that can be played for cash."' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
fi

#Add Plist value to respect view controller status bar appearance
if ! PlistBuddy -c 'Print UIViewControllerBasedStatusBarAppearance' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}";
then
    PlistBuddy -c 'Delete :UIViewControllerBasedStatusBarAppearance' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
    PlistBuddy -c 'Add :UIViewControllerBasedStatusBarAppearance bool YES' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
fi

#Add Custom URL Scheme unique to your game.
bundleId=$(PlistBuddy -c "Print CFBundleIdentifier" "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}" )
customURLScheme="skillz.gamelinks.$bundleId"

if ! PlistBuddy -c 'Print CFBundleURLTypes' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}";
then
    PlistBuddy -c 'Add :CFBundleURLTypes array' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
    PlistBuddy -c 'Add :CFBundleURLTypes: dict' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
    PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLName string $customURLScheme" "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
    PlistBuddy -c 'Add :CFBundleURLTypes:0:CFBundleURLSchemes array' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
    PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string $customURLScheme" "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
else
#Only add our custom scheme if it does not yet exist
if ! grep --quiet $customURLScheme "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}";
then
temporaryPlistPath=$(dirname "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}")/urlScheme.plist
rm -f "$temporaryPlistPath"

    cat > $temporaryPlistPath <<- EOM
        <array>
            <dict>
                <key>CFBundleURLName</key>
                <string>$customURLScheme</string>
                <key>CFBundleURLSchemes</key>
                <array>
                    <string>$customURLScheme</string>
                </array>
            </dict>
        </array>
EOM

printf -v var "PlistBuddy -c \"Merge %q :CFBundleURLTypes:\" %q/%q" "$temporaryPlistPath" "${BUILT_PRODUCTS_DIR}" "${INFOPLIST_PATH}"
eval $var
rm "$temporaryPlistPath"
fi
fi

# Set up localization.
if ! PlistBuddy -c 'Print CFBundleLocalizations:' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
then
    PlistBuddy -c 'Add :CFBundleLocalizations array' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
    PlistBuddy -c 'Add :CFBundleLocalizations:0 string en' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
    PlistBuddy -c 'Add :CFBundleLocalizations:1 string de' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
    PlistBuddy -c 'Add :CFBundleLocalizations:2 string es' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
    PlistBuddy -c 'Add :CFBundleLocalizations:3 string fr' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
    PlistBuddy -c 'Add :CFBundleLocalizations:4 string it' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
    PlistBuddy -c 'Add :CFBundleLocalizations:5 string ja' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
    PlistBuddy -c 'Add :CFBundleLocalizations:6 string pt' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
    PlistBuddy -c 'Add :CFBundleLocalizations:7 string ru' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
    PlistBuddy -c 'Add :CFBundleLocalizations:8 string zh-Hans' "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
fi

echo "code sign identity ${EXPANDED_CODE_SIGN_IDENTITY}"
dylib="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Skillz.framework/Skillz"
signFramework="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Skillz.framework"

if [ ${DEPLOYMENT_LOCATION} = "YES" ]
then
    echo 'Exporting for release, remove unused archs.'

    if file "$dylib" | [ "$(grep -c i386)" -ge 1 ];
    then
        tempfile=`mktemp -t skillz`
        /usr/bin/lipo -output ${tempfile} -remove i386 -remove x86_64 "${dylib}"
        unlink "$dylib"
        mv $tempfile "$dylib"
        echo 'Arch found, removing'
    else
        echo 'Arch not found'
    fi

    rm -- "$0"

    if [ -n "${EXPANDED_CODE_SIGN_IDENTITY}" ] && [ -e "$signFramework" ]
    then
        echo 'Signing Skillz for archive'
        /usr/bin/codesign --force --verbose --sign "${EXPANDED_CODE_SIGN_IDENTITY}" --preserve-metadata=identifier,entitlements,resource-rules "$signFramework"
    else
        echo 'Not signing framework'
    fi

else

    if [ -n "${EXPANDED_CODE_SIGN_IDENTITY}" ] && [ -e "$signFramework" ]
    then
        echo 'Signing Skillz'
        /usr/bin/codesign --force --verbose --sign "${EXPANDED_CODE_SIGN_IDENTITY}" --preserve-metadata=identifier,entitlements,resource-rules "$signFramework"
    else
        echo 'Not signing framework'
    fi
fi

