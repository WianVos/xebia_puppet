class opendj::ubuntu {

	case $lsbdistcodename {
		lucid : { include opendj::ubuntu::lucid }
		default : { notice "unsupported ubuntu release"}
	}
}
