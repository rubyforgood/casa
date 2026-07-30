#!/usr/bin/env ruby
# Pixel-compares two chevrons/icons in a screenshot: prints an ASCII luminance map plus the ink
# bounding box and ink-pixel count for each region. Use it to check a `.ts-wrapper::after` caret
# against a native `<i class="bi bi-chevron-down">` in the SAME screenshot -- darkest-pixel alone is
# only a colour check (see design.md, "Verify a chevron at the pixel level").
#
# Decodes the PNG with nothing but stdlib zlib: there is no image gem in this environment.
#
# Usage: bin/caret-map.rb tmp/shot.png "typeahead caret:903:192" "native chevron:715:192"
# (labels must not contain a colon -- the arg is split on it)
require "zlib"

# Luminance -> glyph, darkest first.
INK_RAMP = [[160, "#"], [210, "+"], [245, "."]].freeze

def read_png(path)
  data = File.binread(path)
  pos = 8
  idat = +""
  w = h = depth = ctype = nil
  while pos < data.bytesize
    len = data[pos, 4].unpack1("N")
    type = data[pos + 4, 4]
    body = data[pos + 8, len]
    case type
    when "IHDR" then w, h, depth, ctype = body.unpack("NNCC")
    when "IDAT" then idat << body
    end
    pos += 12 + len
  end
  raise "unsupported png #{depth}/#{ctype}" unless depth == 8 && [2, 6].include?(ctype)

  bpp = (ctype == 6) ? 4 : 3
  raw = Zlib::Inflate.inflate(idat)
  stride = w * bpp
  prev = Array.new(stride, 0)
  rows = []
  h.times do |y|
    off = y * (stride + 1)
    f = raw.getbyte(off)
    line = raw.byteslice(off + 1, stride).bytes
    stride.times do |i|
      a = (i >= bpp) ? line[i - bpp] : 0
      b = prev[i]
      c = (i >= bpp) ? prev[i - bpp] : 0
      line[i] = case f
      when 0 then line[i]
      when 1 then (line[i] + a) & 0xff
      when 2 then (line[i] + b) & 0xff
      when 3 then (line[i] + ((a + b) / 2)) & 0xff
      when 4
        p = a + b - c
        pa, pb, pc = (p - a).abs, (p - b).abs, (p - c).abs
        pred = if pa <= pb && pa <= pc
          a
        elsif pb <= pc
          b
        else
          c
        end
        (line[i] + pred) & 0xff
      end
    end
    prev = line
    rows << line
  end
  {w: w, h: h, bpp: bpp, rows: rows}
end

img = read_png(ARGV[0])
ARGV[1..].each do |spec|
  label, x, y = spec.split(":")
  x = x.to_f.round
  y = y.to_f.round
  puts "\n  #{label} (centre #{x},#{y})"
  xs = []
  ys = []
  lums = []
  ((y - 7)..(y + 7)).each do |py|
    line = ((x - 12)..(x + 12)).map do |px|
      r, g, b = img[:rows][py][px * img[:bpp], 3]
      lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
      lums << lum
      if lum < 230
        xs << px
        ys << py
      end
      INK_RAMP.find { |threshold, _| lum < threshold }&.last || " "
    end.join
    puts "    |#{line}|"
  end
  if xs.any?
    puts format("    ink %dx%d px, mean lum %.1f, darkest %.1f, ink pixels %d",
      xs.max - xs.min + 1, ys.max - ys.min + 1, lums.sum / lums.size, lums.min, xs.size)
  else
    puts "    NO INK in the box"
  end
end
