# Deployit Python script

import sys, re
print sys.argv

permissions = sys.argv[1].split(',')
permissions.pop()

principals = sys.argv[2].split(',')
principals.pop()

cis = []
if len(sys.argv) > 3:
	cis = sys.argv[3].split(',')
	cis.pop()

print "Granting permissions",permissions,"to principals",principals,"on CIs",cis

for prin in principals:
	for perm in permissions:
		if len(cis) == 0:
			security.grant(perm, prin)
		else:
			security.grant(perm, prin, cis)
