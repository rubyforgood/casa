casa_orgs = CasaOrg.all

placement_types = [
  'Reunification',
  'Custody/Guardianship by a relative',
  'Custody/Guardianship by a non-relative',
  'Adoption by relative',
  'Adoption by a non-relative',
  'APPLA'
]

casa_orgs.each do |org|
  placement_types.each do |label|
    PlacementType.where(name: label, casa_org: org).first_or_create
  end
end
