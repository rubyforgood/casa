#!/bin/sh

# Decrypt the file
mkdir $HOME/secrets
# --batch to prevent interactive command
# --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$QUARANTINE_SERVICE_ACCOUNT_PASSPHRASE" \
--output ./spec/quarantine/service-account.json ./spec/quarantine/service-account.json.gpg
