if (!req.http.fastly-csi-request-id) {
  set req.http.fastly-csi-request-id = now.sec substr(digest.hash_sha256(randomstr(64) req.http.host req.url req.http.Fastly-Client-IP server.identity), 0, 21);
  set req.http.fastly-soc-x-request-id = req.http.fastly-csi-request-id;    
}