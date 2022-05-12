vcl 4.1;

import proxy;

backend default {
    .host = "mysite_nginx";
    .port = "80";
}

backend mysite {
    .host = "mysite_nginx";
    .port = "80";
}

sub vcl_recv {
    if (proxy.is_ssl()) {
        set req.http.X-Forwarded-Proto = "https";
    } else {
        set req.http.X-Forwarded-Proto = "http";
    }
    if(req.http.host == "www.mysite.local" ) {
        set req.backend_hint = mysite;
    }
}
