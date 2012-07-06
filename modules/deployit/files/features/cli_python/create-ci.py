# Deployit Python script

import sys, re
print sys.argv

id = sys.argv[1]
type = sys.argv[2]

values = {}
for i in range(3, len(sys.argv)):
	arg = sys.argv[i]
	match = re.search("^(\w+)=(.*)$", arg)
	if match != None:
		values[match.group(1)] = match.group(2)

print "Creating CI with id ",id," and type", type, " values ", values

try:
	ci = repository.read(id)

except:
	ci = factory.configurationItem(id, type, values)
	print "Created CI:", ci

	repository.create(ci)

else:
	ci.values = values

	repository.update(ci)
