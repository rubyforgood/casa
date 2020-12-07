# Emancipation Checklist Form Data
category_housing = EmancipationCategory.create(name: "Youth has housing.", mutually_exclusive: true)
category_housing.add_option("With friend")
category_housing.add_option("With relative")
category_housing.add_option("With former foster parent")
category_housing.add_option("Subsidized (e.g., FUP, Future Bridges, adult services)")
category_housing.add_option("Independently (e.g., renting own apartment or room)")

category_income = EmancipationCategory.create(name: "Youth has income to achieve self-sufficiency.", mutually_exclusive: false)
category_income.add_option("Employment")
category_income.add_option("Public benefits/TCA")
category_income.add_option("SSI")
category_income.add_option("SSDI")
category_income.add_option("Inheritance/survivors benefits")

category_budget = EmancipationCategory.create(name: "Youth has completed a budget.", mutually_exclusive: false)
category_budget.add_option("Completed budget")

category_employment = EmancipationCategory.create(name: "Youth is employed.", mutually_exclusive: true)
category_employment.add_option("Part-time job")
category_employment.add_option("Full-time job")
category_employment.add_option("Apprenticeship or paid internship")
category_employment.add_option("Self-employed")

category_continuing_education = EmancipationCategory.create(name: "Youth is attending an educational or vocational program.", mutually_exclusive: true)
category_continuing_education.add_option("High school")
category_continuing_education.add_option("Post-secondary/college")
category_continuing_education.add_option("Vocational")
category_continuing_education.add_option("GED program")

category_high_school_diploma = EmancipationCategory.create(name: "Youth has a high school diploma or equivalency.", mutually_exclusive: true)
category_high_school_diploma.add_option("Traditional")
category_high_school_diploma.add_option("Out of school program")
category_high_school_diploma.add_option("GED")

category_medical_insurance = EmancipationCategory.create(name: "Youth has medical insurance.", mutually_exclusive: false)
category_medical_insurance.add_option("Has medical insurance card")
category_medical_insurance.add_option("Knows his/her/their primary care entity")
category_medical_insurance.add_option("Knows how to continue insurance coverage")
category_medical_insurance.add_option("Knows that dental insurance ends at age 21")
category_medical_insurance.add_option("Has plan for dental care")

category_allies = EmancipationCategory.create(name: "Youth can identify permanent family and/or adult connections.", mutually_exclusive: false)
category_allies.add_option("Has connections")

category_community = EmancipationCategory.create(name: "Youth is accessing community activities.", mutually_exclusive: false)
category_community.add_option("Arts activities (e.g., singing, dancing, theater)")
category_community.add_option("Religious affiliations (e.g., church, mosque)")
category_community.add_option("Athletics/team sports")
category_community.add_option("Other")

category_documents = EmancipationCategory.create(name: "Youth has all identifying documents.", mutually_exclusive: false)
category_documents.add_option("Birth certificate (original or certified copy)")
category_documents.add_option("Social security card")
category_documents.add_option("Learner's permit")
category_documents.add_option("Driver's license")
category_documents.add_option("Immigration documents")
category_documents.add_option("State identification card")

category_transportation = EmancipationCategory.create(name: "Youth has access to transportation.", mutually_exclusive: false)
category_transportation.add_option("Vehicle")
category_transportation.add_option("Public transportation")

category_juvenile_criminal_cases = EmancipationCategory.create(name: "Youth has been or is involved in past or current juvenile cases.", mutually_exclusive: false)
category_juvenile_criminal_cases.add_option("All juvenile issues have been resolved.")
category_juvenile_criminal_cases.add_option("All eligible juvenile records have been expunged.")

category_adult_criminal_cases = EmancipationCategory.create(name: "Youth has been or is involved in past or current adult criminal cases.", mutually_exclusive: false)
category_adult_criminal_cases.add_option("All adult criminal cases have been resolved.")
category_adult_criminal_cases.add_option("All eligible adult criminal records have been expunged.")

category_civil_cases = EmancipationCategory.create(name: "Youth has been or is involved in civil or family cases.", mutually_exclusive: false)
category_civil_cases.add_option("All civil or family cases have been resolved.")

category_bank_account = EmancipationCategory.create(name: "Youth has a bank account in good standing.", mutually_exclusive: false)
category_bank_account.add_option("Checking")
category_bank_account.add_option("Savings")

category_credit = EmancipationCategory.create(name: "Youth has obtained a copy of his/her/their credit report.", mutually_exclusive: false)
category_credit.add_option("An adult has reviewed the credit report with Youth.")
category_credit.add_option("Issues or concerns")

category_values = EmancipationCategory.create(name: "Youth can identify his/her/their core values.", mutually_exclusive: false)
category_values.add_option("Identified values")

category_assessment = EmancipationCategory.create(name: "Youth has completed the Ansell Casey Assessment.", mutually_exclusive: false)
category_assessment.add_option("Threshold for self-sufficiency was met.")
