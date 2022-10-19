# CASA Product Sense
This will help you understand the high level thought process that has driven the ideation and development of casavolunteertracking.org. 
## Who is this for?
This is essential reading for anyone stepping into a **lead product role** on this project – particularly for team leads managing stakeholder relationships. It is recommended reading for contributing product managers, and would provide helpful but not essential context to contributing developers. 
### Historical Context
Casavolunteertracking.org was initially developed to help a <a href="https://pgcasa.org/">CASA organization in Prince George's County, Maryland</a> track and manage volunteer activity. PG / CASA was the first official pilot organization for this platform, and served as the primary stakeholders consulted throughout development until <a href="https://voicesforchildrenmontgomery.org/">a second CASA organization in Montgomery County, Maryland</a> joined in early 2021. 
### Early Approach
The MVP requirements for this application were exclusively focused on solving the immediate needs of PG / CASA. Their volunteers at the time had virtually no system for logging time spent with foster youth, and this was the immediate gap we sought to fill. Making the application usable for **volunteers** to log `case_contacts` was the top priority that informed the order of our backlog.

After we had a working volunteer user experience as defined by that topline requirement, we focused on giving PG / CASA staff **supervisors** and **admins** a window into that activity in accordance with their user permissions (admins can see/do everything, supervisors can see/do almost everything that relates to volunteers and cases but not staff users or organization settings).
### Post MVP Approach and Shift to Multitenancy
While we continued to work closely with PG / CASA to improve the MVP experience post production launch, it was around this time that we shifted gears and started focusing on multitenancy.

CASA is an organization founded in Seattle, WA with a nationwide presence. County level chapters operate relatively independent of each other and of the national organization (the national org mostly focuses on policy advocacy, with the county level orgs providing services to foster youth in the form of community volunteers). The baseline operations of each CASA chapter are more or less the same, but the terminology they use and day-to-day processes vary slightly. 

In order for casavolunteetracking.org to be a successful multitenant application, it needs to be clearly tailored for the specific needs of CASA staff and volunteers, yet customizable enough to serve CASA chapters all over the country – without becoming so complicated that it's difficult to use. (Salesforce could be a great solution for CASA chapters if they had the resources to hire a developer who can help set up, customize, and maintain a Salesforce instance. The overwhelming majority of CASA chapters do not have those resources at their disposal.) 
### Questions to Help Guide You
The stakeholders on this project are enthusiastic and filled with ideas! Most of them have been serving their respective CASA organizations for _decades_ and have lots of experience. When a stakeholder from one CASA organization suggests a new feature or improvement, it's important to also solicit feedback on this idea from stakeholders representing a _different_ CASA organization. This will help you begin to understand how a single feature may be used (or not used) at scale.

Presently, this project only has stakeholders representing two CASA organizations from the same state. That means the product and team leads will have to flex their product sense when translating stakeholder feedback into platform changes.
#### Do all CASA chapters do it that way, or just this one? 
This is the top question that should be asked before ticketing out any feature changes. The answer to this is often,
- Yes, but with slight variations.

It is rare that a feature change or idea is suggested that wouldn't be used by at least some CASA chapters. The key is to develop features that benefit the users it's useful to, but don't hinder those who don't require it. 

_Here is a real example that demonstrates this:_

In some counties, the judge overseeing a court hearing varies and is very important information for a volunteer to have ahead of a court date. Yet in other counties, the same judge will always oversee the court appearances for a particular case, so isn't something a volunteer considers when preparing for court. 

Instead of _always_ showing `judge_name` with court details on a `casa_case`, `judge_name` only appears if an `admin` has added it to their `casa_org`.
#### Is the problem this solves a problem every CASA faces?

The answer to this question should be yes as frequently as possible. The more work in development that answers "yes" to this question, the more ways this platform can attract (and help) more CASA chapters. The bigger the problem and the more CASAs that face it, the higher up in the backlog it should go. 

In order to answer this question, it's important to understand the core operations of a CASA chapter:

- volunteer logs `case_contacts` representing time spent with youth (a.k.a. `casa_case`)
- volunteer provides detailed reports on a `casa_case` to the court
- volunteers help prepare eligible `casa_cases` for emancipation
- volunteers help establish permanency plans for their assigned `casa_case`
- supervisors coach volunteers and hold them accountable
- admins maintain a birds eye view that allows them to measure impact, generate stats for fundraising, and provide strategic leadership

The fewer resources that are required to perform those core operations, the better. If a solution being developed improves the efficiency of conducting these core operations, then it probably solves a problem every CASA faces – and henceforth, delivers a big value-add to current and prospective tenants.

#### Would this be “nice to have” for most CASA chapters? Or would this offer a big enough value-add to attract new tenants?

This application currently only has two tenant organizations. In order to scale the platform’s impact, it must serve more tenants. The answer to the previous question can help inform the answer to this one, but it's not the only factor to consider. 

There are currently two market SaaS applications that solve many of the same problems casavolunteertracking.org seeks to, but at a (literal) cost. Apart from being too pricey for many CASA chapters to use, the CASAs that _do_ use one of those market solutions don't find them user friendly and aren't happy with the scope of solutions they offer.

If a solution..
- solves a problem every CASA faces
- does something a market solution doesn't do
- does something a market solution _does_ do, but way better

then it is a winner! (and should be prioritized)
