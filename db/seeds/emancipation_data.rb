# Emancipation Checklist Form Data
category_housing = EmancipationCategory.where(name: "Youth has housing.").first_or_create(mutually_exclusive: false)
category_housing.add_option("With friend")
category_housing.add_option("With relative")
category_housing.add_option("With former foster parent")
category_housing.add_option("Subsidized (e.g., FUP, Future Bridges, adult services)")
category_housing.add_option("Independently (e.g., renting own apartment or room)")

category_income = EmancipationCategory.where(name: "Youth has income to achieve self-sufficiency.").first_or_create(mutually_exclusive: false)
category_income.add_option("Employment")
category_income.add_option("Public benefits/TCA")
category_income.add_option("SSI")
category_income.add_option("SSDI")
category_income.add_option("Inheritance/survivors benefits")

EmancipationCategory.where(name: "Youth has completed a budget.").first_or_create(mutually_exclusive: false)

category_employment = EmancipationCategory.where(name: "Youth is employed.").first_or_create(mutually_exclusive: true)
category_employment.add_option("Part-time job")
category_employment.add_option("Full-time job")
category_employment.add_option("Apprenticeship or paid internship")
category_employment.add_option("Self-employed")

category_continuing_education = EmancipationCategory.where(name: "Youth is attending an educational or vocational program.").first_or_create(mutually_exclusive: true)
category_continuing_education.add_option("High school")
category_continuing_education.add_option("Post-secondary/college")
category_continuing_education.add_option("Vocational")
category_continuing_education.add_option("GED program")

category_high_school_diploma = EmancipationCategory.where(name: "Youth has a high school diploma or equivalency.").first_or_create(mutually_exclusive: true)
category_high_school_diploma.add_option("Traditional")
category_high_school_diploma.add_option("Out of school program")
category_high_school_diploma.add_option("GED")

category_medical_insurance = EmancipationCategory.where(name: "Youth has medical insurance.").first_or_create(mutually_exclusive: false)
category_medical_insurance.add_option("Has medical insurance card")
category_medical_insurance.add_option("Knows his/her/their primary care entity")
category_medical_insurance.add_option("Knows how to continue insurance coverage")
category_medical_insurance.add_option("Knows that dental insurance ends at age 21")
category_medical_insurance.add_option("Has plan for dental care")

EmancipationCategory.where(name: "Youth can identify permanent family and/or adult connections.").first_or_create(mutually_exclusive: false)

category_community = EmancipationCategory.where(name: "Youth is accessing community activities.").first_or_create(mutually_exclusive: false)
category_community.add_option("Arts activities (e.g., singing, dancing, theater)")
category_community.add_option("Religious affiliations (e.g., church, mosque)")
category_community.add_option("Athletics/team sports")
category_community.add_option("Other")

category_documents = EmancipationCategory.where(name: "Youth has all identifying documents.").first_or_create(mutually_exclusive: false)
category_documents.add_option("Birth certificate (original or certified copy)")
category_documents.add_option("Social security card")
category_documents.add_option("Learner's permit")
category_documents.add_option("Driver's license")
category_documents.add_option("Immigration documents")
category_documents.add_option("State identification card")

category_transportation = EmancipationCategory.where(name: "Youth has access to transportation.").first_or_create(mutually_exclusive: false)
category_transportation.add_option("Vehicle")
category_transportation.add_option("Public transportation")

category_juvenile_criminal_cases = EmancipationCategory.where(name: "Youth has been or is involved in past or current juvenile cases.").first_or_create(mutually_exclusive: false)
category_juvenile_criminal_cases.add_option("All juvenile issues have been resolved.")
category_juvenile_criminal_cases.add_option("All eligible juvenile records have been expunged.")

category_adult_criminal_cases = EmancipationCategory.where(name: "Youth has been or is involved in past or current adult criminal cases.").first_or_create(mutually_exclusive: false)
category_adult_criminal_cases.add_option("All adult criminal cases have been resolved.")
category_adult_criminal_cases.add_option("All eligible adult criminal records have been expunged.")

EmancipationCategory.where(name: "Youth has been or is involved in civil or family cases.").first_or_create(mutually_exclusive: false)

category_bank_account = EmancipationCategory.where(name: "Youth has a bank account in good standing.").first_or_create(mutually_exclusive: false)
category_bank_account.add_option("Checking")
category_bank_account.add_option("Savings")

category_credit = EmancipationCategory.where(name: "Youth has obtained a copy of his/her/their credit report.").first_or_create(mutually_exclusive: false)
category_credit.add_option("An adult has reviewed the credit report with Youth.")
category_credit.add_option("Issues or concerns")

EmancipationCategory.where(name: "Youth can identify his/her/their core values.").first_or_create(mutually_exclusive: false)
EmancipationCategory.where(name: "Youth has completed the Ansell Casey Assessment.").first_or_create(mutually_exclusive: false)
