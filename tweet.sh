#!/bin/bash

#######
# ABOUT
    #
    # tweet.sh (ShellTweet)
    #
    # :desc:     Simple shell script to post tweets using the v1.1 API
    # :author:   Terrence Harvey <dev@eatmycode.io>
    # :license:  MIT License
    # :link:     http://github.com/eatmycode/tweet.sh
    # :example:  $ tweet.sh this is pretty dope!


######
# HELP
    #
    # A Lil' Quick How-to.

        if [[ "$1" == "-help" ]] || [[ "$1" == "-h" ]] || [[ -z "$*" ]]
        then
            echo
            echo "    :script:   tweet.sh (ShellTweet)"
            echo "    :author:   Terrence Harvey <dev@eatmycode.io>"
            echo "     :usage:"
            echo "               Option 1. Direct tweet (no prompt)"
            echo "                     Ex."
            echo "                         ~$ tweet this is pretty dope!"
            echo "                         NOTE: ONLY if using this option (1),"
            echo "                               all \"hastags\" must be escaped with a '\'"
            echo
            echo "               Option 2. Prompt for message"
            echo "                     Ex."
            echo "                         ~$ tweet"
            echo "                           Whatchu Tweetin' ? [140 pls]: "
            echo
            echo
            exit 0
        fi

######
# PREP
    #
    # Your Twitter application's settings.
    # [EDIT THIS SECTION TO REFLECT YOUR TWITTER APPLICATION'S VALUES]

        app_key="YOUR_CONSUMER_KEY"
        app_secret="YOUR_CONSUMER_SECRET"
        access_token="YOUR_ACCESS_TOKEN"
        access_secret="YOUR_ACCESS_SECRET"

    # Cache file of previously sent tweets:

        cache="/tmp/previous.shelltweets"


##############
# REQUIREMENTS
    #
    # Simple check for current OS
    # Date builtin on OSX is not the same as on Linux.
    # We need the date for OAuth.
    # [NO NEED TO EDIT THIS SECTION]

        platform='unknown'
        unamestr=$(uname)
        if [[ "$unamestr" == 'Linux' ]]
        then
            unix_time=$(date -d "$(date +"%Y/%m/%d %H:%M:%S")" "+%s")
        elif [[ "$unamestr" == 'FreeBSD' ]] || [[ "$unamestr" == 'Darwin' ]]
        then
            unix_time=$(date -j -f "%a %b %d %T %Z %Y" "$(date)" "+%s")
        fi

    # Check for and set the available encryption tool [ ie. OpenSSL, PHP ]
    # Defaults to PHP or failsback to OpenSSL (provided either is installed)
    # which at least one of them typically would be:

        if [[ -a "/usr/bin/php" ]] || [[ -z $(which php|grep -o "which: no") ]]
        then
            hasher="php"
        elif [[ -a "/usr/bin/openssl" ]] || [[ -z $(which openssl|grep -o "which: no") ]]
        then
            hasher="openssl"
        elif [[ -a "/usr/bin/curl" ]] || [[ -z $(which curl|grep -o "which: no") ]]
        then
            echo "Unfortunately cURL is not installed."
            echo "Please install cURL. See https://github.com/eatmycode/tweet.sh for more information."
            echo
            exit 0
        else
            echo "Neither of the preferred encryption tools (OpenSSL & PHP) are installed."
            echo "Please install OpenSSL or PHP. See https://github.com/eatmycode/tweet.sh for more information."
            echo
            exit 0
        fi


#############
# URLENCODING
    #
    # Helper for percent encoding (urlencode) strings.
    # If PHP is installed, urlencoding will be handled by PHP as this should be
    # futureproof. However, if not, failsback to using bash builtins.
    # [NO NEED TO EDIT THIS SECTION]

        urlenc(){
            if [[ "$hasher" == "php" ]]
            then
                echo "$(php -r "echo rawurlencode('$(sed "s/'/\\\\'/g" <<< "$1")');")"
            elif [[ "$hasher" == "openssl" ]]
            then
                local LANG=en_US.ISO8859-1 ch i
                for ((i=0;i<${#1};i++))
                do
                    ch="${1:i:1}"
                    [[ $ch =~ [._~A-Za-z0-9-] ]] && echo -n "$ch" || printf "%%%02X" "'$ch"
                done
            fi
        }


#############
# TWITTER APP
    #
    # API Auth & Communication:
    # [NO NEED TO EDIT THIS SECTION]

        oauth_method="POST"
        oauth_version="1.0"
        oauth_url="https://api.twitter.com/1.1/statuses/update.json"
        oauth_consumer_key=$(urlenc $"$app_key";echo)
        oauth_nonce=$unix_time
        oauth_signature_method="HMAC-SHA1"
        oauth_timestamp=$unix_time
        oauth_token=$(urlenc $"$access_token";echo)
        oauth_params=$(echo " \
            $(urlenc $"oauth_consumer_key";echo)=$(urlenc $"$oauth_consumer_key";echo)& \
            $(urlenc $"oauth_nonce";echo)=$(urlenc $"$oauth_nonce";echo)& \
            $(urlenc $"oauth_signature_method";echo)=$(urlenc $"$oauth_signature_method";echo)& \
            $(urlenc $"oauth_timestamp";echo)=$(urlenc $"$oauth_timestamp";echo)& \
            $(urlenc $"oauth_token";echo)=$(urlenc $"$oauth_token";echo)& \
            $(urlenc $"oauth_version";echo)=$(urlenc $"$oauth_version";echo)& \
            $(urlenc $"status";echo)=$(urlenc $"$status_message";echo)"|sed 's/ //g'
        )
        oauth_signature_base=$(echo "$oauth_method&$(urlenc $"$oauth_url";echo)&$(urlenc $"$oauth_params";echo)")
        oauth_signature_key=$(echo "$(urlenc $"$app_secret";echo)&$(urlenc $"$access_secret";echo)")

        # Signs request using HMAC-SHA1 via openssl or php
        # depending on whats installed:

            if [[ "$hasher" == "php" ]]; then
                oauth_signature_hashed_via_php=$(
                    echo "<?php echo base64_encode(hash_hmac(\"sha1\", \"$oauth_signature_base\", \"$oauth_signature_key\", true)); ?>"|php
                )
                oauth_signature=$(urlenc $"$oauth_signature_hashed_via_php";echo)
            elif [[ "$hasher" == "openssl" ]]; then
                oauth_signature_hashed_via_openssl=$(
                    echo -n "$oauth_signature_base"|openssl sha1 -hmac "$oauth_signature_key" -binary|base64
                )
                oauth_signature=$(urlenc $"$oauth_signature_hashed_via_openssl";echo)
            fi
            oauth_header=$(echo "Authorization: OAuth oauth_consumer_key=\"$oauth_consumer_key\", \
                                                      oauth_nonce=\"$oauth_nonce\", \
                                                      oauth_signature=\"$oauth_signature\", \
                                                      oauth_signature_method=\"$oauth_signature_method\", \
                                                      oauth_timestamp=\"$oauth_timestamp\", \
                                                      oauth_token=\"$oauth_token\", \
                                                      oauth_version=\"$oauth_version\" "|sed 's/  //g'
            )


############
# POST TWEET
    #
    # Read input:

        if [[ -n "$(echo "$@"|grep -Eio [A-Za-z0-9])" ]]
        then
            status_message=$(echo "$@"|sed 's/\\//g';)
        else
            echo
            read -p "Whatchu Tweetin' ? [140 pls]: " status_message
        fi

    # Send data:

        result=$(curl \
                  --request "POST" "$oauth_url" \
                  --data "status=$(urlenc $"$status_message";echo)" \
                  --header "$oauth_header" \
                  -s
        )

    # Print the result:

        echo
        if [ -z $(echo "$result"|grep -o "errors") ]
        then
            echo "Tweeted It!"
            exit 0
        else
            echo "Error: [ $result ]"
            echo 1
        fi
        echo


# EOF