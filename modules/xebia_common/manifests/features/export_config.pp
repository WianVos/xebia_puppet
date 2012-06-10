define xebia_common::features::export_config(
	$confdir 	= 	'',
	$options 	=	'',
	$tag		= 	'',
	$timestamp	=	inline_template("<%= Time.now.strftime('%Y-%m-%dT%H:%M:%S%z') %>"),
	$maxage 	= 	"28800"
){
	
	# check age of facts ..
	$age = inline_template("<%= require 'time'; Time.now - Time.parse(timestamp) %>")
	
	
	file{"${name}":
			path 	=> "${confdir}/$name.txt",
			require => File["${confdir}"],
			tag => $tag,
			content => inline_template("<% options.sort_by {|key, value| key}.each do |key, value| %><%= key %>='<%= value %>' \n<% end %>")
	}	
}
