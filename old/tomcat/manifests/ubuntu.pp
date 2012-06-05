class tomcat::ubuntu {

	case $::lsbdistcodename {
		lucid : { include tomcat::ubuntu::lucid }
		default : { notice "unsupported ubuntu release"}
	}
}
