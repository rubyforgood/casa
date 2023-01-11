TDD these changes.

1) http://localhost:3000/casa_cases/cina-03-1005/edit - This is a case that belongs to CASA Org 1 (Prince George CASA)
2) Logging in to CASA Org 2 admin, I should not be able to reach that page.

Looks like it 404'd but we should redirect to our own scoped cases.

Based on the edit spec, it seems we are already scoping most actions to the current organization. So far, the system specs are performing as the Issue requests.

I think the strategy here is to continue through the specs to add cases to validate the behaviour.

It may be that the request specs will reveal some undesired behaviour.