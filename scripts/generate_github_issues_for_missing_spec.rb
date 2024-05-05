# for every xit test
Dir.glob("spec/**/*spec.rb").each do |filename|
  File.open(filename, "r").readlines.select { |line| line.include?("xit \"") }.each do |xit_line|
    line_number = $.
    clean_test_name = xit_line.gsub("xit ", "").gsub(" do\n", "").gsub('"', "").gsub("\n", "").strip
    # clean_test_name = xit_line.gsub('xit', '').gsub('\"do.*', '').gsub('"', '').gsub("\n", '').strip
    title = "Fix or remove xit-ignored test in #{filename}:#{line_number} '#{clean_test_name}'"
    `gh issue create --title "#{title}" --body "#{title}"`
  end
end; nil
