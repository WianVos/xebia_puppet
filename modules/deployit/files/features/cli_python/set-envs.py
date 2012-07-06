# Deployit Python script

import sys, re
print sys.argv

id = sys.argv[1]

if len(sys.argv) > 2:
	envs = []
	for i in range(2, len(sys.argv)):
		envs.append(sys.argv[i])

	print "Adding CI with id",id,"to environments",envs

	for env in envs:
		try:
			envCi = repository.read(env)
		except:
			# Create environment first
			envCi = factory.configurationItem(env, 'udm.Environment')
			repository.create(envCi)
			envCi = repository.read(env)
		
		if envCi.members == None:
			envCi.members = [ id ]
		else:
			envCi.members = envCi.members + [ id ]

		repository.update(envCi)
