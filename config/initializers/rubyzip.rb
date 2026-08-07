# frozen_string_literal: true

require "zip"

# rubyzip 3 flipped write_zip64_support to true by default (it was false in 2.x).
#
# Sablon builds court reports with Zip::OutputStream.write_buffer, which streams entries
# without knowing their sizes up front, so with zip64 on, every entry is written with
# version-needed 45 and 0xFFFFFFFF size placeholders. Microsoft Word rejects zip64 OOXML
# packages outright — "The file isn't in the correct format" — even though unzip, rubyzip
# and the docx gem all read them happily, which is why our specs never noticed. See #7093.
#
# Turning it off means we cannot write archives over 4GB or with more than 65,535 entries.
# Court reports and spreadsheet exports are nowhere near either limit, and Excel dislikes
# zip64 for the same reason Word does, so caxlsx benefits from this too.
Zip.write_zip64_support = false
