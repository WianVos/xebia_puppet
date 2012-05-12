class deployit(
	$ensure = "present",
	$completeVersion = "3.7"
){

case $::operatingsystem {
                Ubuntu  : { include deployit::ubuntu}
                default : { notice "unsupported operatingsystem ${::operatingsystem}" }
                }



}
