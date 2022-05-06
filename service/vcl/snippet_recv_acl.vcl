if(fastly.ff.visits_this_service == 0 && req.http.Fastly-Client-IP !~ allow_list) {
    error 403 "Forbidden";
}