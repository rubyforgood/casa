# 2. Disallow user sign-ups from the UI

Date: 2020-04-04

## Status

Accepted

## Context

We want it to be easy for people to join the organization, however we don't want random people signing up and spamming us. We want admin users to have control over who has accounts on the system. We don't have the capacity to handle this properly through the user interface right now.

## Decision

We are going to disable Devise 'registerable' for the user model so that there will no longer be a public sign up option on the site. Creation of new accounts will be done on the backend.

## Consequences

Admins have to do more work to sign up users, but this gives them more control over who can access the site.