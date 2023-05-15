### POST `/casa_cases.json`  
Creates a casa case
### Params:  
 - **casa_case**  
  Required. Contains all the object containing all the casa case params
   - **case_number**: "CINA-123-ABC",  
     Required. A unique string to identify the casa case
   - **transition_aged_youth**: true,  
     A boolean marking the case as transitioning or not. Currently in the process of deprecating this field
   - **birth_month_year_youth**: "2007-10-21",  
     Required. A date in the format YYYY-MM-DD determining if the case as transitioning or not.
   - **casa_org_id**: 1,  
     Required. The id of the casa org of the case. 
   - **hearing_type_id**: 1,  
     The id of the hearing type for the next court date.
   - **judge_id**: 1  
     The id of the case judge

### POST `/case_assignments.json`
Creates a case_assignment
- **Params:**
   - **casa_case_id**: 1,  
     Required. The id of the casa case the volunteer is being assigned to.
   - **volunteer_id**: 1,  
     Required. The id of the volunteer being assigned to the casa case.

### PATCH   `/case_assignments/:id/unassign.json`
Unassigns a case_assignment
- **Params:**
   - **id**: 1,  
     Required. The id of the case_assignment to be unassigned.
