define postgresql::export_service_db(
	$timestamp	=	inline_template("<%= Time.now.strftime('%Y-%m-%dT%H:%M:%S%z') %>"),
	$maxage 	= 	"28800",
	$service 	= 	"",
	$role		=	"",
	$customer	=	"",
	$application =  "",
	$universe	=	"",
	$hostname	=   "${::hostname}",
	$config_dir	=	params_lookup('configdir'),
	$use_concat =   true,
	$concat_target = "",
	$concat_options = "",
	$concat_seperator = " = ",
	$concat_owner	=	"root",
	$concat_group	=	"root",
	$config_options	= 	"",
	$use_config	= 	false
	
){
	
	# check age of facts ..
	$age = inline_template("<%= require 'time'; Time.now - Time.parse(timestamp) %>")
	
	if $age < $maxage {
		if $use_concat {
			if !defined(Concat["${concat_target}"]){
				include concat::setup
				concat {
					"${concat_target}" :
					owner => "${concat_owner}",
					group => "${concat_group}",
					mode => "0770",				
				}	
			}
			concat::fragment {
				"${concat_target} ${customer}_${application}_${::hostname}" :
					target => "${concat_target}",
					content =>
					inline_template("<% concat_options.sort_by {|key, value| key}.each do |key, value| %><%= key %><%= concat_seperator %><%= value %> \n<% end %>"),
					order => 01,
			}
		}
		if $use_config {
		$config_file	=	"${config_dir}/${service}-${role}.txt"
		file {
			"${customer}_${application}_${::hostname}" :
				path => "${config_file}",
				require => File["${config_dir}"],
				tag => $tag,
				content =>
				inline_template("<% options.sort_by {|key, value| key}.each do |key, value| %><%= key %>='<%= value %>' \n<% end %>")
			}
		
		}
	}
}
