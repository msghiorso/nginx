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
	
	location ~ \.php$
	{
		fastcgi_pass 127.0.0.1:9000;
		fastcgi_index   index.php;
		fastcgi_param   SCRIPT_FILENAME $document_root/$fastcgi_script_name;
		include         fastcgi_params;
	}
}	
