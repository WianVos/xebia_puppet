import traceback
import getopt

def usage(): 
    print 'Usage' 
    print 'wlst weblogic.py [-u domain_utility.py] [-t weblogic_template] [-s schemes] [-p property] [-d]'
    print 'wlst weblogic.py [--utility domain_utility.py] [--template weblogic_template] [--schemes schemes] [--properties property] [--dry-run]'
    
def parse_input():
    utility = 'domain_utility.py'
    template = 'weblogic_template'
    schemes = 'schemes'
    properties = 'properties'
    dry_run = False
    
    try:
        opts, remainder = getopt.getopt(sys.argv[1:], "u:t:s:p:d", ["utility=", "template=", "schemes=", "properties=","dry-run"])

        for opt, arg in opts:
            if opt in ('-u', '--utility'):
                 utility = arg
                 print 'Using utility module ' + utility
            if opt in ('-t', '--template'):
                 template = arg
                 print 'Using template ' + template
            if opt in ('-s', '--schemes'):
                 schemes = arg
                 print 'Using schemes ' + schemes
            if opt in ('-p', '--properties'):
                 properties = arg
                 print 'Using properties ' + properties
            if opt in ('-d', '--dry-run'):
                 print 'Starting in dry-run'
                 dry_run = True

        return (utility, template, schemes, properties, dry_run)
    except getopt.GetoptError,exc:
        usage()
        
# This script requires the domain_utility.py from the WebLogic Building Block
try:  
    print "Creating WebLogic Domain"
    utility, template_module, schemes_module, properties_module, dryrun = parse_input()
    execfile(utility)
    template = vars(__import__(template_module))
    properties = vars(__import__(properties_module))
    schemes = vars(__import__(schemes_module))['schemes']
    configuration=getProcessedDomainConfiguration(template, schemes, properties)
    createAndConfigureDomain(configuration)
    writeConfiguredDomain(configuration, dryrun)
    #exit()
except  Exception, (e):
    print "ERROR: An unexpected error occurred!"
    traceback.print_exc()
    dumpStack()
    print 'ERROR: Failed to create domain ' + configuration.domain_name + '!!'
