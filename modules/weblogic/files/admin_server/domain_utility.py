from __future__ import generators
from copy import deepcopy
import re

#---------------------------------------------------------------------------------------------------
# generic templating system
#---------------------------------------------------------------------------------------------------

# A type specific combiner, used in combining dictionary values (other than dict objects itself)
# if the types are equal, use the combiner function to combine a and b
class Combiner(object): 
    def __init__(self, clazz, combinerFunction):
        self.clazz = clazz
        self.combinerFunction = combinerFunction

    def canCombine(self, a, b):
        return isinstance(a, self.clazz) and isinstance(b, self.clazz)

    def combine(self, a, b):
        if self.canCombine(a, b):
            return self.combinerFunction(a, b)
        return None

class ArgumentPattern:
    def __init__(self, name_pattern, value_pattern, separator=''):
        self.name_pattern = name_pattern
        self.value_pattern = value_pattern
        self.separator = separator
    
    def isArgument(self, arg):
        return re.match(self.getArgumentPattern(), arg)

    def getArgumentPattern(self): 
        def makeGroupPattern(pattern): 
            group_pattern='\(.+\)'
            if re.match(group_pattern, pattern):
                return pattern
            else:
                return '(%s)' % pattern

        return makeGroupPattern(self.name_pattern) + self.separator + makeGroupPattern(self.value_pattern)
 
    def getArgumentName(self, arg):
        match = self.isArgument(arg)
        
        if match:
            return match.group(1)
        else: 
            return None

    def getArgumentValue(self, arg):
        match = self.isArgument(arg)
        
        if match:
            return match.group(2)
        else: 
            return None
		
# A combiner function as used in a Combiner
# If b starts with a '*' return a merged string. 
# All terms, tokens in the string separated by space are mapped to arguments
# i.e. -Xms1024m is the argument -Xms
# a, b -> -Xms1024, -Xms2048M -> -Xms2048M 
# (see below for the known argument patterns) 
# Non-known arguments are just appended to the string
#
# If b starts with a '+' return a + b[1:] 
# , i.e concatenating the string excluding the '+'
#
# In all other situations b is returned
def mergeStringCombiner(a, b):
   if b.startswith('+'):
       return a + b[1:]
   elif b.startswith('*'):
       aterms = a.split()
       bterms = b[1:].split()
	   
	   # these are well known argument patterns which have a name and value component
       argument_patterns = [ArgumentPattern('-Xms','\d+[m|g|M|G]'),
                            ArgumentPattern('-Xmx','\d+[m|g|M|G]'),
                            ArgumentPattern('-Xmn','\d+[m|g|M|G]'),
                            ArgumentPattern('-Xss','\d+[m|g|M|G]'),
                            ArgumentPattern('-Xoss','\d+[m|g|M|G]'),
                            ArgumentPattern('-[^XD].*','.+',':'),
                            ArgumentPattern('-X[^X].*','.+',':'),
                            ArgumentPattern('-XX:.+','.+','='),
                            ArgumentPattern('-D.+','.+','=')]
							
       def filterKnownArgs (terms): return [( arg.getArgumentName(term), term ) for term in terms for arg in argument_patterns if arg.isArgument(term)]
       # filter all terms in a and b which are *known* argument patterns
       a_args = dict(filterKnownArgs(aterms))
       b_args = dict(filterKnownArgs(bterms))
	   
       # final arguments, start with all from a
       final_args = aterms
       # all remaining terms which aren't already in a or are an argument in b_args
       remaining_terms = [ bterm for bterm in bterms if bterm not in aterms]
       #[ bterm for bterm in bterms if bterm not in b_args.values() and bterm not in aterms]

       # override/append with args from b
       for b_arg_name, b_arg_value in b_args.iteritems():
           if b_arg_name in a_args:
               # if already defined in a insert at same position
               final_args.insert(final_args.index(a_args[b_arg_name]), b_arg_value)
               final_args.remove(a_args[b_arg_name])
               if b_arg_value in remaining_terms:
                   remaining_terms.remove(b_arg_value)

       final_args = final_args + remaining_terms
              
       return ' '.join(final_args)
   else:
       return b

def uniq(alist):
    set = {}
    return [set.setdefault(e,e) for e in alist if e not in set]

def listCombiner(a, b):
   if a == b:
       return a
   else: 
       return uniq(a + b)

def filterDictionaryItems(dictionary, predicate=lambda k, v: True):
    for k, v in dictionary.items(): 
        if predicate(k, v):
            yield (k, v)

def isDefault(key): return key.endswith('_default')

def isTemplate(key): return key.endswith('_template')

def getDefaultProperties(properties): return dict(
    filterDictionaryItems(properties, lambda k,v: isDefault(k)))

def getTemplateProperties(properties): return dict(
    filterDictionaryItems(properties, lambda k,v: isTemplate(k)))

def getGenericGlobalProperties(properties): return dict(
    filterDictionaryItems(properties, lambda k,v: not isTemplate(k) and not isDefault(k)))

# Combined dictionaries (nested)
#
# >>> combineDictionaries({'1':1,'2':2},{'2':'two','3':'3'})
# {'1': 1, '3': '3', '2': 'two'}
# >>> combineDictionaries({'1':1,'2':{'2.1':'2.1'}},{'2':{'2.2':'2.2', '2.3':'2.3'},'3':'3'})
# {'1': 1, '3': '3', '2': {'2.3': '2.3', '2.2': '2.2', '2.1': '2.1'}}
def combineDictionaries(g, s, combiners={list: Combiner(list, listCombiner)}):
    combined = deepcopy(g)
    
    for i_key, i_value in s.iteritems():
        if g.has_key(i_key):
            if isinstance(g[i_key], dict) and isinstance(s[i_key], dict) :
                combined[i_key] = combineDictionaries(g[i_key], s[i_key], combiners)
            else: 
                if combiners.has_key(type(i_value)):
                    combiner = combiners[type(i_value)]
                    combined[i_key] = combiner.combine(g[i_key], i_value)
                else: 
                    combined[i_key] = i_value
        else:
           combined[i_key] = i_value
            
    return combined
    
def applyReplacements(template_value, replacements):
    value=template_value
    for prop_name, prop_value in replacements.iteritems():
        if isinstance(template_value, str):
            value=value.replace(prop_name, prop_value)
        elif isinstance(template_value, dict): 
            dicted = {} 
            for dict_prop_name, dict_prop_value in template_value.iteritems():
                dicted.update(dict({dict_prop_name: applyReplacements(dict_prop_value, replacements)}))
            value = dicted
        elif isinstance(template_value, list):
            value = [template_value_item.replace(prop_name,prop_value) for template_value_item in value]
    return value

# Apply template on the list of machines/servers/clusters/etc (applied_to_list) and merge 
# and return the applied template with the specific properties of this environment .
def applyTemplate(template, applied_to_list, specific_properties):
    appliedTemplate = dict(specific_properties)
    number=0
    for template_item, parent_item in applied_to_list: 
        number+=1
        template_instance=deepcopy(template) 
        
        if template_item in specific_properties and isinstance(template, dict):
            template_instance = combineDictionaries(template, deepcopy(specific_properties[template_item]), {str: Combiner(str, mergeStringCombiner)})

        # standard template replacements <domain_name>, <listen_port+n> within dictionary properties
        if isinstance(template_instance, dict):
            for key, value in template_instance.iteritems():
                template_instance[key]=applyReplacements(value, {'<domain_name>':specific_properties['domain_name'], '<number>':str(number), 
                    '<instance_name>':template_instance.get('Name', specific_properties.get(parent_item, {}).get('Name', 'UNKNOWN_NAME'))})
                match = re.search('<listen_port\+(\d+)>', str(value))
                if match != None:
                    managed_server = appliedTemplate['managed_servers'][number - 1]
                    template_instance[key] = applyReplacements(template_instance[key], 
                        {match.group(0): str(appliedTemplate[managed_server]['ListenPort'] + int(match.group(1)))})
        # standard template replacement <managed_server> in list properties, i.e. referral properties
        elif isinstance(template_instance,list): 
            managed_server = appliedTemplate['managed_servers'][number - 1]
            template_instance = applyReplacements(template_instance, {'<managed_server>':managed_server})
        
        appliedTemplate[template_item]=template_instance
    
    return appliedTemplate
  
# Apply the known templates  
def applyTemplates(template_properties, specific_properties):
    appliedTemplates = dict(specific_properties)

    appliedTemplates = applyTemplate(template_properties['machine_template'],
        [ (x, x) for x in specific_properties['machines']], specific_properties)
    appliedTemplates = applyTemplate(template_properties['cluster_template'],
        [ (x, x) for x in specific_properties['clusters']], appliedTemplates)
        
    # applyManagedServerTemplates
    appliedTemplates = applyTemplate(template_properties['managed_server_template'],
        [ (x, x) for x in specific_properties['managed_servers']], appliedTemplates)
    
    # applyManagedServerTemplates
    appliedTemplates = applyTemplate(template_properties['virtual_host_template'],
        [ (x, x) for x in specific_properties.get('virtual_hosts',[])], appliedTemplates)
        
    # applySubTemplates of main categories (managed_server/virtual_host)
    def getConfigNames(config):
        managed_server_template_matcher = re.compile('^' + config + '_(.+)_template$')
        for k, v in template_properties.items(): 
            match = managed_server_template_matcher.match(k)
            if match:
                yield match.group(1)
   
    for sub in getConfigNames('managed_server'):
        appliedTemplates = applyTemplate(template_properties['managed_server_' + sub + '_template'], 
           [(x + '_' + sub, x) for x in specific_properties['managed_servers']], appliedTemplates)

    for sub in getConfigNames('virtual_host'):
        appliedTemplates = applyTemplate(template_properties['virtual_host_' + sub + '_template'], 
           [(x + '_' + sub, x) for x in specific_properties.get('virtual_hosts',[])], appliedTemplates)
           
    return appliedTemplates
    
def applyDefaults(default_properties, specific_properties): 
    unapplied_defaults=dict([(k[:-len('_default')], v) for k, v in default_properties.iteritems()])
    applied_defaults=deepcopy(unapplied_defaults)
    
    for default_key, default_value in applied_defaults.iteritems():
        applied_defaults[default_key]=applyReplacements(
            default_value, {'<domain_name>':specific_properties['domain_name']})
    
    return applied_defaults

def applyScheme(properties, scheme_properties):
    appliedScheme = dict(properties)
    
    for property_key, property_value in scheme_properties.iteritems():
        if isinstance(property_value, dict) and properties.has_key(property_key): 
            appliedScheme[property_key] = combineDictionaries(properties[property_key], property_value)
        else: 
            appliedScheme[property_key] = property_value
            
    return appliedScheme
        
def getProcessedDomainConfiguration(generic_properties, schemes, specific_properties):
    generic_default_properties = schemed_default_properties = getDefaultProperties(generic_properties)
    generic_template_properties = schemed_template_properties = getTemplateProperties(generic_properties)
    generic_global_properties = getGenericGlobalProperties(generic_properties)
    

    if specific_properties.has_key('scheme'):
        if schemes.has_key(specific_properties['scheme']):
            scheme=schemes[specific_properties['scheme']]
            schemed_default_properties = applyScheme(generic_default_properties, getDefaultProperties(scheme))
            schemed_template_properties = applyScheme(generic_template_properties, getTemplateProperties(scheme))
        else:
            print 'ERROR UNKNOWN SCHEME'
            exit(exitcode=1)
        
    applied_defaults=applyDefaults(schemed_default_properties, specific_properties)
    applied_templates=applyTemplates(schemed_template_properties, specific_properties)
    
    instance_properties = combineDictionaries(generic_global_properties, applied_defaults) 
    instance_properties = combineDictionaries(instance_properties, specific_properties) 
    instance_properties = combineDictionaries(instance_properties, applied_templates) 
    
    # if servers to clusters is not specified and there's only one cluster 
    # defined, assign all servers to this one cluster
    if not instance_properties.has_key('servers_to_clusters'):
        if len(instance_properties['clusters']) == 1:
            clusterref = instance_properties['clusters'][0]
            clustername = instance_properties[clusterref]['Name']
            servernames=[]
            cluster_member_addresses=[]
            for managed_server_ref in instance_properties['managed_servers']:
                servernames.append(instance_properties[managed_server_ref]['Name'])
                cluster_member_addresses.append(
                    instance_properties[managed_server_ref]['ListenAddress'] + ':' +
                    str(instance_properties[managed_server_ref]['ListenPort']))
            instance_properties['servers_to_clusters']={clustername: servernames}

            if not instance_properties[clusterref].has_key('ClusterAddress'):
                cluster_address = {'ClusterAddress': ','.join(cluster_member_addresses)}
                instance_properties[clusterref] = combineDictionaries(instance_properties[clusterref], cluster_address)
            
            instance_properties[clusterref] = combineDictionaries(instance_properties[clusterref], {'NumberOfServersInClusterAddress': len(cluster_member_addresses)})
        else: 
            print "ERROR There's no explicit servers_to_clusters property defined, and there \
                are multiple clusters defined, THERE ARE NO SERVER TO CLUSTER ASSIGNMENTS"
            # don't allow this; user should specify an explicit assignment of servers to clusters
            exit(exitcode=1) 
    
    # if the Administration Port is enabled, 
    if instance_properties['domain'].get('AdministrationPortEnabled', False):
        for managed_server_ref in instance_properties['managed_servers']:
            management_server_arg={'Arguments': '+ -Dweblogic.management.server=https://' + instance_properties['admin_server']['ListenAddress'] + ':' + 
                str(instance_properties['admin_server']['AdministrationPort'])}
            instance_properties[managed_server_ref + '_serverstart'] = combineDictionaries(instance_properties[managed_server_ref + '_serverstart'],
                management_server_arg, {str: Combiner(str, mergeStringCombiner)})
    
    return instance_properties
    
#---------------------------------------------------------------------------------------------------
# wlst specific
#---------------------------------------------------------------------------------------------------

def assignServerToCluster(serverName, clusterName):
    print 'Assigning ' + serverName + ' to ' + clusterName
    assign('Server', serverName, 'Cluster', clusterName)

def assignServersToCluster(serverNames, clusterName):
    assignServerToCluster(','.join(serverNames), clusterName)

def configureAdminServer(properties):
    print 'Configuring AdminServer'
    setProperties('/Server/AdminServer', properties)

def configureDomain(properties):
    print 'Configuring Domain'
    setProperties('/', properties)
    
def configureDomainLogging(domain_name, properties):
    if (not(doesChildExists('/', 'Log'))):
        cd('/')
        create(domain_name, 'Log')
        
    setProperties('/Log/' + domain_name, properties)
        
def configureJdbcResource(name, username, password, properties):
    print 'Configuring JDBC Resource ' + name
    jdbcResourceRoot = '/JDBCSystemResource/' + name + '/JdbcResource/' + name
    # Set username and password
    cmo = cd(jdbcResourceRoot + '/JDBCDriverParams/NO_NAME_0')
    cmo.setPasswordEncrypted(password)
    cd('Properties/NO_NAME_0/Property/user')
    set('Value', username)
    
    print jdbcResourceRoot + '/JDBCDriverParams/NO_NAME_0/Properties/NO_NAME_0/Property/user.Value=' + username
    print jdbcResourceRoot + '/JDBCDriverParams/NO_NAME_0.passwordEncrypted=******'
    
    # Set dictionary passed properties
    connectionPoolParams = properties['JDBCConnectionPoolParams']
    setProperties(jdbcResourceRoot + '/JDBCConnectionPoolParams/NO_NAME_0', connectionPoolParams)
   
    dataSourceParams = properties['JDBCDataSourceParams']
    setProperties(jdbcResourceRoot + '/JDBCDataSourceParams/NO_NAME_0', dataSourceParams)
    
    driverParams = properties['JDBCDriverParams']
    setProperties(jdbcResourceRoot +  '/JDBCDriverParams/NO_NAME_0', driverParams)
    
def configureServerLogging(serverName, properties): 
    print 'Configure Logging for Server ' + serverName
    
    if (not(doesChildExists('/Servers/' + serverName, 'Log'))):
        create(serverName, 'Log')
        
    setProperties('/Servers/' + serverName + '/Log/' + serverName, properties)

def configureServerStart(serverName, properties):
    print 'Configuring Server Start for Server ' + serverName
    
    if (not(doesChildExists('/Servers/' + serverName, 'ServerStart'))):
        create(serverName, 'ServerStart')
    
    setProperties('/Servers/' + serverName + '/ServerStart/' + serverName, properties)

def configureVirtualHostLogging(virtual_host, properties):
    if (not(doesChildExists('/VirtualHost/' + virtual_host, 'WebServerLog'))):
        cd('/VirtualHost/' + virtual_host)
        create(virtual_host, 'WebServerLog')
    
    setProperties('/VirtualHost/' + virtual_host + '/WebServerLog/' + virtual_host, properties)
        
def configureWebServer(serverName, properties):
    print 'Configuring Web Server for Server ' + serverName

    if (not(doesChildExists('/Servers/' + serverName, 'WebServer'))):
        cd('/Servers/' + serverName)
        create(serverName, 'WebServer')
    
    if (properties.has_key('WebServerLog')):
        if (not(doesChildExists('/Servers/' + serverName + '/WebServer/' + serverName, 'WebServerLog'))):
            cd('/Servers/' + serverName + '/WebServer/' + serverName)
            create(serverName, 'WebServerLog')
        
        setProperties('/Servers/' + serverName + '/WebServer/' + serverName + '/WebServerLog/' + serverName, properties['WebServerLog'])
    
def createCluster(name, properties):
    print 'Creating Cluster ' + name
    cd ('/')
    create(name, 'Cluster')
    setProperties('/Cluster/' + name, properties)
    
def createMachine(name):
    print 'Creating UnixMachine ' + name 
    cd('/')
    create(name, 'UnixMachine')

def createNetworkAccessPoint(name, serverName, properties):
    print 'Creating Channel ' + name + ' for server ' + serverName
    cd('/Servers/' + serverName)
    create(name, 'NetworkAccessPoint')
    setProperties('/Servers/' + serverName + '/NetworkAccessPoints/' + name, properties)
     
def createNodeManager(machineName, properties):
    print 'Creating NodeManager for machine ' + machineName
    cd('/Machine/' + machineName)
    create(machineName,'NodeManager')
    setProperties('/Machine/' + machineName + '/NodeManager/' + machineName, properties)
    
def createServer(name, properties=None):
    print 'Creating Server ' + name
    if (not(doesChildExists('/Servers', name))):
        cd('/')
        create(name, 'Server')
    else:
        print 'INFO Server ' + name + ' already exists'
    
    setProperties('/Server/' + name, properties)

def createUser(name, properties=None):
    print 'Creating User ' + name

    if (not(doesChildExists('/Security/base_domain/User', name))):
        cd('/Security/base_domain/User')
        cmo = create(name, 'User')
    else:
        print 'INFO User ' + name + ' already exists'
        
    setProperties('/Security/base_domain/User/' + name, properties)
 
def createVirtualHost(name, properties): 
    print 'Creating Virtual Host ' + name
    
    if (not(doesChildExists('/', 'VirtualHost')) or not(doesChildExists('/VirtualHost', name))):
        cd('/')
        cmo = create(name, 'VirtualHost')
    else:
        print 'INFO VirtualHost ' + name + ' already exists'
        
    setProperties('/VirtualHost/' + name, properties)

def deleteAppDeployment(name):
    print 'Deleting AppDeployment ' + name
    
    if (not(doesChildExists('/AppDeployment', name))):
        print 'WARN AppDeployment ' + name + ' does not exists, failed to remove'
    else:
        cd('/')
        delete(name, 'AppDeployment')
    
def doesChildExists(parent, child):
    cd(parent)
    children = ls(returnMap='true', returnType='c')
    
    if (children.indexOf(child) == -1):
        return False
    else:
        return True
    
def renameServer(originalName, newName):
    print 'Renaming Server ' + originalName + ' to ' + newName
    setProperties('/Server/' + originalName, {'Name':newName})
    
def setProperties(context, properties):
    cd(context)

    # If property is specified, there is an order in which the properties are to be set
    setorder_key = '__setorder__'
    comparator = cmp
    if  properties.has_key(setorder_key):
        setorder = properties[setorder_key]
        del properties[setorder_key]

        def setorderer(x, y):
            def getValue(val):
                if val in setorder:
                    return setorder.index(val)
                else:
                    return None

            a = getValue(x)
            b = getValue(y)

            if a is None and b is not None:
                result = 1
            elif a is not None and b is None:
                result = -1
            else:
                result = cmp(a, b)

            return result
        comparator = setorderer

    keys = properties.keys()
    keys.sort(comparator)
    for key in keys:
        print context + '.' + key + "=" + str(properties[key])
        set(key, properties[key])

        
def templates(baseTemplate, extensionTemplates):
    print 'Reading base template ' + baseTemplate
    readTemplate(baseTemplate)
    
    if len(extensionTemplates) > 0:
        print 'Adding ' + str(len(extensionTemplates)) + ' extension template(s).'
        
        for extensionTemplate in extensionTemplates:
            print 'Adding extension template ' + extensionTemplate
            addTemplate(extensionTemplate)

def createAndConfigureDomain(properties):
    templates(properties['baseTemplate'], properties['extensionTemplates'])

    # Create Machines 
    for machine in properties['machines']:
        machineName = properties[machine]['Name']
        createMachine(machineName)
        createNodeManager(machineName, properties[machine])
    
    # Reuse template created servers
    for originalName, newName in properties['rename_servers'].items():
        renameServer(originalName, newName)

    # Create servers
    for server in properties['managed_servers']:
        try: 
            server_properties = properties[server]
        except KeyError:
            print 'ERROR: Exiting NO properties found for ' + server + '!!'
            print 'ERROR: Please specify properties for server ' + server + '!!'
            exit(exitcode=1)
         
        createServer(server_properties['Name'], server_properties)
        configureServerLogging(server_properties['Name'], properties[server + '_logging'])
        configureServerStart(server_properties['Name'], properties[server + '_serverstart'])
        configureWebServer(server_properties['Name'], properties[server + '_webserver'])
        
        for network_access_point in properties[server + '_network_access_points']:
            try: 
                network_access_point_properties = properties[network_access_point]
            except KeyError:
                print 'ERROR: Exiting NO properties found for ' + network_access_point + '!!'
                print 'ERROR: Please specify properties for network_access_point ' + network_access_point + '!!'
                exit(exitcode=1)
            createNetworkAccessPoint(network_access_point_properties['Name'], server_properties['Name'], network_access_point_properties)
                
    # Create clusters
    for cluster in properties['clusters']:
        try: 
            cluster_properties = properties[cluster]
        except KeyError:
            print 'ERROR: Exiting NO properties found for ' + cluster + '!!'
            print 'ERROR: Please specify properties for cluster ' + cluster + '!!'
            exit(exitcode=1)
            
        createCluster(cluster_properties['Name'], cluster_properties)
     
    # Assign servers to clusters   
    for cluster, servers in properties['servers_to_clusters'].items():
        assignServersToCluster(servers, cluster)
    
    # Create Virtual Hosts
    for virtual_host in properties['virtual_hosts']:
        try: 
            virtual_host_properties = properties[virtual_host]
        except KeyError:
            print 'ERROR: Exiting NO properties found for ' + virtual_host + '!!'
            print 'ERROR: Please specify properties for virtual host ' + virtual_host + '!!'
            exit(exitcode=1)

        createVirtualHost(virtual_host_properties['Name'], virtual_host_properties)
        configureVirtualHostLogging(virtual_host_properties['Name'], properties[virtual_host + '_logging'])
        
    # Create users
    for user in properties['users']:
        try: 
            user_properties = properties[user]
        except KeyError:
            print 'ERROR: Exiting NO properties found for ' + user + '!!'
            print 'ERROR: Please specify properties for user ' + user + '!!'
            exit(exitcode=1)
            
        createUser(user_properties['Name'], user_properties)
        
    # Configure the AdminServer  
    configureAdminServer(properties['admin_server'])
    configureServerLogging('AdminServer', properties['admin_server_logging'])
    configureWebServer('AdminServer', properties['admin_server_webserver'])
    
    # Configure JDBC Resources
    for jdbc in properties['jdbcresources']:
        try:
            jdbc_properties = properties[jdbc]
            jdbc_name = properties[jdbc + '_name']
            jdbc_username = properties[jdbc + '_username']
            jdbc_password = properties[jdbc + '_password']
            configureJdbcResource(jdbc_name, jdbc_username, jdbc_password, jdbc_properties)
        except KeyError:
            print 'ERROR: Exiting missing property for jdbc resource ' + jdbc
            exit(exitcode=1)

    # Delete (unnecessary) AppDeployments
    if properties.has_key('delete_app_deployments'):
        for app_deployment in properties['delete_app_deployments']:
           deleteAppDeployment(app_deployment)
    
    # End game
    configureDomain(properties['domain'])
    configureDomainLogging(properties['domain_name'], properties['domain_logging'])
    cmo = cd('/')
    cmo.setProductionModeEnabled(properties['production_mode_enabled'])
    cmo = cd('/Security/base_domain/User/weblogic')
    cmo.setPassword(properties['weblogic_password'])
    
def createBootPropertiesFile(domain_dir, username, password) :
    if not os.path.exists(domain_dir + "/servers/" + "AdminServer" + "/security"):
        os.makedirs(domain_dir + "/servers/" + "AdminServer" + "/security")
        filename=(domain_dir + "/servers/" + "AdminServer" + "/security/boot.properties")
        f=open(filename, 'w')
        line='username=' + username + '\n'
        f.write(line)
        line='password=' + password + '\n'
        f.write(line)
        f.close()
    else:
        print 'domain_dir + "/servers/" + "AdminServer" + "/security" exists'
       
def writeConfiguredDomain(properties, dry_run=False):
    ##
    # Final Domain Configuration
    ##
    cd('/')
    setOption('AppDir', properties['app_dir'])
    setOption('ServerStartMode',(properties['production_mode_enabled']) and 'prod' or 'dev')
    setOption('OverwriteDomain',properties['overwrite_domain'])
    setOption('JavaHome', properties['java_home'])

    print 'Configured domain ' + properties['domain_name'] + ', used properties saved to ' + properties['domain_name'] + '.properties'
    file(properties['domain_name'] + '.properties', 'w').write(repr(properties))
    
    if (not(dry_run)):
        writeDomain(properties['domain_dir'])
        if (properties['production_mode_enabled']):
            createBootPropertiesFile(properties['domain_dir'], 'weblogic', properties['weblogic_password'])
    else:
        print 'Dry run completed, if you still have an interactive session (started with wlst -i), ' + \
                'run: writeDomain(\'' + properties['domain_dir'] + '\') to write the domain to disk'
        if (properties['production_mode_enabled']):
              print 'and createBootPropertiesFile(\'' + properties['domain_dir'] + '\',\'weblogic\','+ '\'' + properties['weblogic_password'] + '\')'

    print 'Successfully created domain ' + properties['domain_name'] + '!!'
