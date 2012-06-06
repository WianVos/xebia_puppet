#
# Permission.pp
#
# Usage:
# deployit::permission { 'grant-read':
#   principals => [ 'john', 'mary', 'developers' ],
#   permissions => [ 'login', 'read' ],
#   cis => [ 'Environments', 'Applications' ],
#   ensure => present / absent
# }

define deployit_cli::features::permission(
	$permissions,
	$principals,
	$cis = [],
	$ensure = present
) {
	if $ensure == present {

		deployit_cli::features::execute { "grant permissions ${permissions} to ${principals} on CIs ${cis}":
			source => "/opt/deployit-puppet-module/grant-permission.py",
			params => inline_template("'<% permissions.each do |val| -%><%= val %>,<% end -%>' '<% principals.each do |val| -%><%= val %>,<% end -%>' '<% cis.each do |val| -%><%= val %>,<% end -%>'"),
		}

	} elsif $ensure == absent {

		deployit_cli::features::execute { "revoke permissions ${permissions} to ${principals} on CIs ${cis}":
			source => "/opt/deployit-puppet-module/revoke-permission.py",
			params => inline_template("'<% permissions.each do |val| -%><%= val %>,<% end -%>' '<% principals.each do |val| -%><%= val %>,<% end -%>' '<% cis.each do |val| -%><%= val %>,<% end -%>'"),
		}
		
	} else {
		notice("Ensure $ensure not supported")
	}
}
