# Emancipation Checklist Form Data
categoryHousing = EmancipationCategory.create(name: "Youth has housing.", mutually_exclusive: true)
categoryHousing.add_option("With friend")
categoryHousing.add_option("With relative")
categoryHousing.add_option("With former foster parent")
categoryHousing.add_option("Subsidized (e.g., FUP, Future Bridges, adult services)")
categoryHousing.add_option("Independently (e.g., renting own apartment or room)")

categoryIncome = EmancipationCategory.create(name: "Youth has income to achieve self-sufficiency.", mutually_exclusive: false)
categoryIncome.add_option("Employment")
categoryIncome.add_option("Public benefits/TCA")
categoryIncome.add_option("SSI")
categoryIncome.add_option("SSDI")
categoryIncome.add_option("Inheritance/survivors benefits")

categoryBudget = EmancipationCategory.create(name: "Youth has completed a budget.", mutually_exclusive: false)
categoryBudget.add_option("Completed budget")

categoryEmployment = EmancipationCategory.create(name: "Youth is employed.", mutually_exclusive: true)
categoryEmployment.add_option("Part-time job")
categoryEmployment.add_option("Full-time job")
categoryEmployment.add_option("Apprenticeship or paid internship")
categoryEmployment.add_option("Self-employed")

categoryContinuingEducation = EmancipationCategory.create(name: "Youth is attending an educational or vocational program.", mutually_exclusive: true)
categoryContinuingEducation.add_option("High school")
categoryContinuingEducation.add_option("Post-secondary/college")
categoryContinuingEducation.add_option("Vocational")
categoryContinuingEducation.add_option("GED program")

categoryHighSchoolDiploma = EmancipationCategory.create(name: "Youth has a high school diploma or equivalency.", mutually_exclusive: true)
categoryHighSchoolDiploma.add_option("Traditional")
categoryHighSchoolDiploma.add_option("Out of school program")
categoryHighSchoolDiploma.add_option("GED")

categoryMedicalInsurance = EmancipationCategory.create(name: "Youth has medical insurance.", mutually_exclusive: false)
categoryMedicalInsurance.add_option("Has medical insurance card")
categoryMedicalInsurance.add_option("Knows his/her/their primary care entity")
categoryMedicalInsurance.add_option("Knows how to continue insurance coverage")
categoryMedicalInsurance.add_option("Knows that dental insurance ends at age 21")
categoryMedicalInsurance.add_option("Has plan for dental care")

categoryAllies = EmancipationCategory.create(name: "Youth can identify permanent family and/or adult connections.", mutually_exclusive: false)
categoryAllies.add_option("Has connections")

categoryCommunity = EmancipationCategory.create(name: "Youth is accessing community activities.", mutually_exclusive: false)
categoryCommunity.add_option("Arts activities (e.g., singing, dancing, theater)")
categoryCommunity.add_option("Religious affiliations (e.g., church, mosque)")
categoryCommunity.add_option("Athletics/team sports")
categoryCommunity.add_option("Other")

categoryDocuments = EmancipationCategory.create(name: "Youth has all identifying documents.", mutually_exclusive: false)
categoryDocuments.add_option("Birth certificate (original or certified copy)")
categoryDocuments.add_option("Social security card")
categoryDocuments.add_option("Learner's permit")
categoryDocuments.add_option("Driver's license")
categoryDocuments.add_option("Immigration documents")
categoryDocuments.add_option("State identification card")

categoryTransportation = EmancipationCategory.create(name: "Youth has access to transportation.", mutually_exclusive: false)
categoryTransportation.add_option("Vehicle")
categoryTransportation.add_option("Public transportation")

categoryJuvenileCriminalCases = EmancipationCategory.create(name: "Youth has been or is involved in past or current juvenile cases.", mutually_exclusive: false)
categoryJuvenileCriminalCases.add_option("All juvenile issues have been resolved.")
categoryJuvenileCriminalCases.add_option("All eligible juvenile records have been expunged.")

categoryAdultCriminalCases = EmancipationCategory.create(name: "Youth has been or is involved in past or current adult criminal cases.", mutually_exclusive: false)
categoryAdultCriminalCases.add_option("All adult criminal cases have been resolved.")
categoryAdultCriminalCases.add_option("All eligible adult criminal records have been expunged.")

categoryCivilCases = EmancipationCategory.create(name: "Youth has been or is involved in civil or family cases.", mutually_exclusive: false)
categoryCivilCases.add_option("All civil or family cases have been resolved.")

categoryBankAccount = EmancipationCategory.create(name: "Youth has a bank account in good standing.", mutually_exclusive: false)
categoryBankAccount.add_option("Checking")
categoryBankAccount.add_option("Savings")

categoryCredit = EmancipationCategory.create(name: "Youth has obtained a copy of his/her/their credit report.", mutually_exclusive: false)
categoryCredit.add_option("An adult has reviewed the credit report with Youth.")
categoryCredit.add_option("Issues or concerns")

categoryValues = EmancipationCategory.create(name: "Youth can identify his/her/their core values.", mutually_exclusive: false)
categoryValues.add_option("Identified values")

categoryAssessment = EmancipationCategory.create(name: "Youth has completed the Ansell Casey Assessment.", mutually_exclusive: false)
categoryAssessment.add_option("Threshold for self-sufficiency was met.")
