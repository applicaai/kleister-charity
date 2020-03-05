#!/bin/bash -xe

if command -v git-annex > /dev/null 2>/dev/null;
then
    :
else
    echo >&2 "You need git-annex to download PDF files!"
    exit 1
fi

# git-annex itself
git config remote.origin.annex-ignore true # to avoid message about the remote not handling git-annex
git fetch -f origin git-annex:git-annex
git annex enableremote pub-aws-s3
git annex get --from pub-aws-s3
