def get_category_by_name(category_name)
  EmancipationCategory.where(name: category_name)&.first
end

get_category_by_name("Youth has completed a budget.")&.delete_option("Completed budget")
get_category_by_name("Youth is employed.")&.delete_option("Not employed")
get_category_by_name("Youth is attending an educational or vocational program.")&.delete_option("Not attending")
get_category_by_name("Youth has a high school diploma or equivalency.")&.delete_option("No")
get_category_by_name("Youth can identify permanent family and/or adult connections.")&.delete_option("Has connections")
get_category_by_name("Youth has been or is involved in civil or family cases.")&.delete_option("All civil or family cases have been resolved.")
get_category_by_name("Youth can identify his/her/their core values.")&.delete_option("Identified values")
get_category_by_name("Youth has completed the Ansell Casey Assessment.")&.delete_option("Threshold for self-sufficiency was met.")
get_category_by_name("Youth has completed the Ansell Casey Assessment.")&.update_attribute(:name, "Youth has completed the Ansell Casey Assessment and threshold for self-sufficiency was met.")
