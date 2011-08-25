server
{
	listen 127.0.0.1:8080;
	server_name localhost.crawfordgroup.com;
	
	root /usr/local/sites/crawfordgroup.com;

	index index.php index.html;

	if (!-e $request_filename)
	{
		rewrite ^(.*)-([0-9]+)\.(css|js|png|swf)$ $1.$3 break;
	}

	location /
        {
                if (!-e $request_filename)
                {
                        rewrite ^.*$ /index.php last;
                }
        }
	
	location ~ \.php(.*)$
	{
		include        fastcgi_params;
		
		# A handy function that became available in 0.7.31 that breaks down 
		# The path information based on the provided regex expression
		# This is handy for requests such as file.php/some/paths/here/ 
		fastcgi_split_path_info ^(/simplesamlphp/www/[a-z]+\.php)(.+)$;
		
		fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
		fastcgi_param  PATH_INFO          $fastcgi_path_info;
		#
		#fastcgi_param  PATH_TRANSLATED    $document_root$fastcgi_path_info;
		fastcgi_param  REQUEST_URI        $request_uri;
				
		fastcgi_pass   127.0.0.1:9000;
		fastcgi_index  index.php;
	}
}	
