class UserInputHelpers
  DANGEROUS_STRINGS = [
    "مرحبا بالعالم هذا اسم من ترجمة جوجل",
    "שלום עולם זה שם מגוגל תרגם",
    '"1\'; DROP TABLE users-- 1"',
    '<<SCRIPT>alert(\"XSS\");//<</SCRIPT>',
    "Dr. Jane Smith, MS; MST; Esq."
  ].freeze
end
