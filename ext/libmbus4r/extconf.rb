require 'mkmf'

if have_library("mbus","mbus_parse")
then
  create_makefile("libmbus4r")
else
  puts "No libmbus support available"
end

