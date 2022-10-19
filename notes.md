### Issue: https://github.com/rubyforgood/casa/issues/2698
# We will remove this file when the PR gets ready to be merged

We found that the user has a [preference_set](https://github.com/JuanVqz/casa/blob/3b29754fe0cad7796607dc49f5d2461f4a1591d3/app/models/user.rb#L33) relationship,
which is the place where we will save the preferences.

How to procced:
  - Create a preference_set controller with create_or_update method
  - Find or create preference_set with the user
  - Add the ajax request [here](https://github.com/JuanVqz/casa/blob/3b29754fe0cad7796607dc49f5d2461f4a1591d3/app/javascript/src/dashboard.js#L322-L331)

Questions to answer:
 - will we need to change the way the preferences are shown? why I'm saying that?
 because the preferences table it's beeing rendered from the Volunteer::TABLE_COLUMNS
 and it should be rendered by user.preference_set relationship.
 - Do we need to add a migration with default preference_set?
 I think it's the better way but requires more time, another alternative is a max of both
 use Volunteer::TABLE_COLUMNS and user.preference_set

  ```rb
  # Volunteer::TABLE_COLUMNS.concat(user.preference_set)
  ["name", "foo"].concat(["bar", "foo"]).uniq
   => ["name", "foo", "bar"]
  ```
