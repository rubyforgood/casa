# 3. Having 2 user tables

Date: 2020-04-05

## Status

Accepted

## Context

This is planned to be a multi-tenant system. There will be multiple CASA orgs in the system, so every case, case_contact, volunteer, supervisor, casa_admin etc must have a casa_org_id, because no one is allowed to belong to multiple CASAs. Volunteer, supervisor, and casa_admin are all roles for a "User" db object. In addition to those existing roles, we want to create a new kind of user: all_casa_admin. We need to handle the case of super users who have access to multiple casa_orgs, so they would be difficult to handle in the existing User table--with null handling around their casa_org_id field. We have used the built-in Devise ability to have multiple user tables, as recommended to us by our Rails expert Betsy. This is to prevent needing null handling around casa_id for User records since all_casa_admin users will not have casa_id populated.

Additionally, all_casa_admin users are currently intended to be allowed to create casa_admin users, but NOT to be able to see or edit any CASA data like volunteer assignments, cases, case_updates etc.

## Decision

We are using two tables for users: "user" table for volunteers,supervisors, and casa_admin (all of which must have a casa_id). "all_casa_admin" for all_casa_admins, which will have no casa_id.

## Consequences

The login behavior and dashboard page for all_casa_admin will need to be created and handled separately from the regular user login and dashboard
