#!/bin/bash
# Instructions:
# -Create an empty directory
# -Put a .txt file in it containing a list of all the urls of the zip files
# -Run this script
# TODO: enhance this script so it will stop when something is broken

FILE=

_usage(){
    cat << EOF
    usage: $0 options
    This script verifies an isis release.
    OPTIONS:  
    -h  Show this message
    -d  <text file> Download  
    -v  Verify
    -u  Unpack  
    -b  Build
    -a <version> Create archetype
EOF
}

_download(){
    while read fil; do
        echo 'Downloading '$fil
        #curl -O $fil
        #curl -O $fil.asc
        wget $fil
        wget $fil.asc
    done <$FILE
}

_verify(){
    for zip in *.zip
    do
        echo 'Verifying '$zip
        gpg --verify $zip.asc $zip
    done
}

_unpack(){
    echo 'Unpacking '
    unzip -q '*.zip'
}

_build(){
    echo 'Removing Isis from local repo '$module
    rm -rf ~/.m2/repository/org/apache/isis
    COUNTER=0
    for module in ./*/
    do
        COUNTER=$[COUNTER+1]
        if [ $COUNTER -eq 1 ]
        then
            cd $module
            echo 'Building Core '$module
            mvn dependency:resolve
            mvn clean install -o
            cd ..
        else
            cd $module
            echo 'Building Module '$module
            mvn clean install -o
            cd ..
        fi
    done
}

_archetype(){
mvn archetype:generate \
    -D archetypeGroupId=org.apache.isis.archetype \
    -D archetypeArtifactId=simpleapp-archetype \
    -D archetypeVersion=$VERSION \
    -D groupId=com.mycompany \
    -D artifactId=myapp \
    -D version=1.0-SNAPSHOT \
    -B \
    -o
cd myapp
mvn clean install
java -jar webapp/target/myapp-webapp-1.0-SNAPSHOT-jetty-console.jar
}


#Main
while getopts "hd:vuba:" OPTION; do
    case $OPTION in
        h)
            _usage
            exit 1
            ;;
        d)
            if [[ -z $OPTARG ]]; then
                _usage
                exit 1
            fi
            FILE=$OPTARG
            _download
            ;;
        v)
            _verify
            ;;
        u)
            _unpack
            ;;
        b)
            _build
            ;;
        a)
            if [[ -z $OPTARG ]]; then
                _usage
                exit 1
            fi
            VERSION=$OPTARG
            _archetype
            ;;
        ?)
            _usage
            exit 1
            ;;
    esac
done
