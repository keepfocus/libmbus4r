require 'mkmf'

if have_library("mbus","mbus_parse")
then
  create_makefile("mbus")
else
  puts "No libmbus support available"
end

