if ( req.request == "FASTLYPURGE" ) {
    set req.http.Fastly-Purge-Requires-Auth = "1";
}