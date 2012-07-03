import traceback

# expected variables
# admin_server_url, username, password, serverName, hostAddress, clusterName
try:  
    connect(admin_server_url, username, password) 
    
    edit()
    startEdit()
    print "Creating Managed Server"
    cd ('/')
    create(serverName, 'Server')
    cd('Server/' + serverName)
    set('ListenAddress', hostAddress)
   
    print "Add managed server to cluster" 
    assign('Server', serverName, 'Cluster', clusterName)

    cd('/')
    create(serverName, 'UnixMachine')
    cd('/Machine/' + serverName)
    create(serverName,'NodeManager')
    cd('/Machine/' + serverName + '/NodeManager/' + serverName) 
    set('ListenAddress', hostAddress) 
    
    save()
    activate()
    disconnect()
    exit()
    
except  Exception, (e):
    print "ERROR: An unexpected error occurred!"
    traceback.print_exc()
    dumpStack()
