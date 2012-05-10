class deployit{

case $::operatingsystem {
                Ubuntu  : { include deployit::ubuntu}
                default : { notice "unsupported operatingsystem ${::operatingsystem}" }
                }



}
