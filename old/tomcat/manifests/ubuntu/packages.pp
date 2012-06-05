class tomcat::ubuntu::packages{

	package { ['openjdk-6-jdk',"liblog4j1.2-java", "libcommons-logging-java"]:	
		ensure => latest,
	}
}
