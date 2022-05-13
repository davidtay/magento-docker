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
    if (req.http.x-forwarded-for) {
         set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + "172.17.0.1";
    } else {
         set req.http.X-Forwarded-For = "172.17.0.1";
    }    
    if(req.http.host == "www.mysite.local" ) {
        set req.backend_hint = mysite;
    }
}
