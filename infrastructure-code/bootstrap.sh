#!/bin/bash

set -ex

cat << EOF > /tmp/iot.patch
diff --git a/routes/index.js b/routes/index.js
index 52d0e7e..bf8732a 100644
--- a/routes/index.js
+++ b/routes/index.js
@@ -45,6 +45,12 @@ router.use(function(req, res, next) {
 	}
 	// for all others, redirect to login page
 	else if(! req.session.api_key && req.path.indexOf('login') === -1) {
+		if( process.env.API_KEY && process.env.AUTH_TOKEN ){
+            console.log("Found API Key and Auth token in Environment")
+            req.session.api_key = process.env.API_KEY;
+            req.session.auth_token = process.env.AUTH_TOKEN;
+            res.redirect("/dashboard");
+        }
 		res.redirect("/login");
 	} else {
 		next();
EOF

export API_KEY="a-cecc0p-tvfjrd6nw9"
export AUTH_TOKEN="tUEl3-7gD5COe2@Ajp"
echo "API_KEY=\"$API_KEY\"" >> /etc/environment && \
echo "AUTH_TOKEN=\"$AUTH_TOKEN\"" >> /etc/environment && \
apt-get -qq update && \
apt-get -qq install git curl gnupg2 gcc g++ make && \
curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
apt-get -qq install nodejs && \
node -v && npm -v && \
git clone https://github.com/ibm-watson-iot/rickshaw4iot.git /opt/rickshaw4iot && \
cd /opt/rickshaw4iot && \
npm install && \
npm install -g pm2 && \
pm2 startup systemd --user root && \
systemctl enable pm2-root && \
pm2 start /opt/rickshaw4iot/app.js