#!/bin/bash
# fail fast
#set -e


NO_SANITY_CHECK=0

while getopts "j:v:" OPT; do
    case "$OPT" in
        j) JIRA=$OPTARG
            ;;
        v) VERSION=$OPTARG
            ;;
    esac
done
shift $((OPTIND-1))

if [ ! "$JIRA" -o ! "$VERSION" ]; then
    echo "usage: $(basename $0) -j [jira] -v [version]" >&2
    echo "   eg: $(basename $0) -j EST-1234 -v 1.7.0-SNAPSHOT" >&2
    exit 1
fi

echo "\$JIRA     = $JIRA"
echo "\$VERSION  = $VERSION"

echo ""
echo "bumping version to $VERSION"
echo ""
mvn versions:set -DnewVersion=$VERSION -DgenerateBackupPoms=false || exit 1  > /dev/null

echo "Committing changes"
git commit -am "$JIRA: bumping to version $VERSION" || exit 1 


if [[ $VERSION != *"SNAPSHOT"* ]]; then
    echo "Tagging"
    git tag $VERSION || exit 1 
    git tag latest || exit 1
fi

