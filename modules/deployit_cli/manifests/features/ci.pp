#
# Ci.pp
#
# Usage:
#   deployit::ci { 'tomcat':
#		id => 'Infrastructure/mydirectory/newhost/tomcat',
#		type => 'tomcat.Server',
#		values => { home => /opt/tomcat, startCommand => start.sh, stopCommand => stop.sh, tags => [ tag1, tag2 ] }
#		environments => [ 'a', 'b', 'c'], # Add CI to environments a, b and c
#		ensure => present / absent / discovered, # Trigger discovery, store discovered resources.
#   }

define deployit_cli::features::ci(
	$ciId,
	$ciType = "undefined",
	$ciValues = {},
	$ciEnvironments = [],
	$ciTags = [],
	$ensure = present,
	$script_dir = "${deployit_cli::params::script_dir}"
) {
	if $ensure == present {

		deployit_cli::features::execute { "create CI ${ciId} of type ${ciType}":
			source 		=> "${script_dir}/create-ci.py",
			params 		=> inline_template("'<%= ciId %>' '<%= ciType %>' <% ciValues.each do |key, val| -%><%= key %>='<%= val %>' <% end -%>"),
		}

		deployit_cli::features::execute { "set tags on CI ${ciId}":
			require 	=> Deployit_cli::Features::Execute["create CI ${ciId} of type ${ciType}"], 
			source 		=> "${script_dir}/set-tags.py",
			params 		=> inline_template("'<%= ciId %>' <% ciTags.each do |val| -%>'<%= val %>' <% end %>"),
		}

		deployit_cli::features::execute { "set environments on CI ${ciId}":
			require		=> Deployit_cli::Features::Execute["set tags on CI ${ciId}"],
			source 		=> "${script_dir}/set-envs.py",
			params 		=> inline_template("'<%= ciId %>' <% ciEnvironments.each do |val| -%>'<%= val %>' <% end %>"),
		}

		
	} elsif $ensure == absent {

		deployit_cli::features::execute { "delete CI ${ciId}":
			source => "${script_dir}/delete-ci.py",
			params => inline_template("'<%= ciId %>'"),
		}
		
	} else {
		notice("Ensure $ensure not supported")
	}

}
