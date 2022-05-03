unset req.http.rqpass;
if (!req.http.fastly-soc-x-request-id) {
  set req.http.fastly-soc-x-request-id = digest.hash_sha256(now randomstr(64) req.http.host req.url req.http.Fastly-Client-IP server.identity);
}