# Emancipation Checklist Form Data
categoryHousing = EmancipationCategory.create(name: "Youth has housing.", mutually_exclusive: true)
categoryHousing.addOption("With friend")
categoryHousing.addOption("With relative")
categoryHousing.addOption("With former foster parent")
categoryHousing.addOption("Subsidized (e.g., FUP, Future Bridges, adult services)")
categoryHousing.addOption("Independently (e.g., renting own apartment or room)")

categoryIncome = EmancipationCategory.create(name: "Youth has income to achieve self-sufficiency.", mutually_exclusive: false)
categoryIncome.addOption("Employment")
categoryIncome.addOption("Public benefits/TCA")
categoryIncome.addOption("SSI")
categoryIncome.addOption("SSDI")
categoryIncome.addOption("Inheritance/survivors benefits")

categoryBudget = EmancipationCategory.create(name: "Youth has completed a budget.", mutually_exclusive: false)
categoryBudget.addOption("Completed budget")

categoryEmployment = EmancipationCategory.create(name: "Youth is employed.", mutually_exclusive: true)
categoryEmployment.addOption("Part-time job")
categoryEmployment.addOption("Full-time job")
categoryEmployment.addOption("Apprenticeship or paid internship")
categoryEmployment.addOption("Self-employed")

categoryContinuingEducation = EmancipationCategory.create(name: "Youth is attending an educational or vocational program.", mutually_exclusive: true)
categoryContinuingEducation.addOption("High school")
categoryContinuingEducation.addOption("Post-secondary/college")
categoryContinuingEducation.addOption("Vocational")
categoryContinuingEducation.addOption("GED program")

categoryHighSchoolDiploma = EmancipationCategory.create(name: "Youth has a high school diploma or equivalency.", mutually_exclusive: true)
categoryHighSchoolDiploma.addOption("Traditional")
categoryHighSchoolDiploma.addOption("Out of school program")
categoryHighSchoolDiploma.addOption("GED")

categoryMedicalInsurance = EmancipationCategory.create(name: "Youth has medical insurance.", mutually_exclusive: false)
categoryMedicalInsurance.addOption("Has medical insurance card")
categoryMedicalInsurance.addOption("Knows his/her/their primary care entity")
categoryMedicalInsurance.addOption("Knows how to continue insurance coverage")
categoryMedicalInsurance.addOption("Knows that dental insurance ends at age 21")
categoryMedicalInsurance.addOption("Has plan for dental care")

categoryAllies = EmancipationCategory.create(name: "Youth can identify permanent family and/or adult connections.", mutually_exclusive: false)
categoryAllies.addOption("Has connections")

categoryCommunity = EmancipationCategory.create(name: "Youth is accessing community activities.", mutually_exclusive: false)
categoryCommunity.addOption("Arts activities (e.g., singing, dancing, theater)")
categoryCommunity.addOption("Religious affiliations (e.g., church, mosque)")
categoryCommunity.addOption("Athletics/team sports")
categoryCommunity.addOption("Other")

categoryDocuments = EmancipationCategory.create(name: "Youth has all identifying documents.", mutually_exclusive: false)
categoryDocuments.addOption("Birth certificate (original or certified copy)")
categoryDocuments.addOption("Social security card")
categoryDocuments.addOption("Learner's permit")
categoryDocuments.addOption("Driver's license")
categoryDocuments.addOption("Immigration documents")
categoryDocuments.addOption("State identification card")

categoryTransportation = EmancipationCategory.create(name: "Youth has access to transportation.", mutually_exclusive: false)
categoryTransportation.addOption("Vehicle")
categoryTransportation.addOption("Public transportation")

categoryJuvenileCriminalCases = EmancipationCategory.create(name: "Youth has been or is involved in past or current juvenile cases.", mutually_exclusive: false)
categoryJuvenileCriminalCases.addOption("All juvenile issues have been resolved.")
categoryJuvenileCriminalCases.addOption("All eligible juvenile records have been expunged.")

categoryAdultCriminalCases = EmancipationCategory.create(name: "Youth has been or is involved in past or current adult criminal cases.", mutually_exclusive: false)
categoryAdultCriminalCases.addOption("All adult criminal cases have been resolved.")
categoryAdultCriminalCases.addOption("All eligible adult criminal records have been expunged.")

categoryCivilCases = EmancipationCategory.create(name: "Youth has been or is involved in civil or family cases.", mutually_exclusive: false)
categoryCivilCases.addOption("All civil or family cases have been resolved.")

categoryBankAccount = EmancipationCategory.create(name: "Youth has a bank account in good standing.", mutually_exclusive: false)
categoryBankAccount.addOption("Checking")
categoryBankAccount.addOption("Savings")

categoryCredit = EmancipationCategory.create(name: "Youth has obtained a copy of his/her/their credit report.", mutually_exclusive: false)
categoryCredit.addOption("An adult has reviewed the credit report with Youth.")
categoryCredit.addOption("Issues or concerns")

categoryValues = EmancipationCategory.create(name: "Youth can identify his/her/their core values.", mutually_exclusive: false)
categoryValues.addOption("Identified values")

categoryAssessment = EmancipationCategory.create(name: "Youth has completed the Ansell Casey Assessment.", mutually_exclusive: false)
categoryAssessment.addOption("Threshold for self-sufficiency was met.")
