namespace :after_party do
  desc "Deployment task: rename app-shipped default contact type groups + types to sentence case"
  task sentence_case_default_contact_types: :environment do
    puts "Running deploy task 'sentence_case_default_contact_types'"

    # ContactTypeGroup::DEFAULT_CONTACT_TYPE_GROUPS is sentence-cased (design system), but orgs
    # seeded before that change still hold the old Title Case names (e.g. "Fictive Kin",
    # "Social Services"). generate_for_org! find_or_creates by name, so it never renames them.
    #
    # Rename ONLY records whose name is a case-variant of a shipped default (LOWER matches, case
    # differs) to the exact sentence-case default -- org-renamed / custom names never match a
    # default and are left untouched ("never force-case free-form org data"). update_all skips
    # callbacks/validations; the sentence-case target did not already exist for these orgs.
    renamed_groups = 0
    renamed_types = 0

    ContactTypeGroup::DEFAULT_CONTACT_TYPE_GROUPS.each do |group_name, type_names|
      group = group_name.to_s
      renamed_groups += ContactTypeGroup
        .where("LOWER(name) = ? AND name <> ?", group.downcase, group)
        .update_all(name: group)

      type_names.each do |type_name|
        renamed_types += ContactType
          .where("LOWER(name) = ? AND name <> ?", type_name.downcase, type_name)
          .update_all(name: type_name)
      end
    end

    # One legacy default also changed punctuation, so it can't match case-insensitively.
    renamed_types += ContactType
      .where(name: "Aunt Uncle or Cousin")
      .update_all(name: "Aunt, uncle, or cousin")

    puts "  renamed #{renamed_groups} contact type group(s) and #{renamed_types} contact type(s)"

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
