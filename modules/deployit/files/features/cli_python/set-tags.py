# Deployit Python script

import sys, re
print sys.argv

id = sys.argv[1]

if len(sys.argv) > 2:
	tags = []
	for i in range(2, len(sys.argv)):
		tags.append(sys.argv[i])

	print "Setting tags",tags,"on CI with id",id

	ci = repository.read(id)

	if ci.tags == None:
		ci.tags = [] + tags
	else:
		ci.tags = ci.tags + tags

	repository.update(ci)
