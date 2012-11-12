require 'mkmf'

if have_library("mbus","main")
then
  create_makefile("mbus")
else
  puts "No libmbus support available"
end

