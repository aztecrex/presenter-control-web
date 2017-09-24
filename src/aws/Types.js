'use strict';

exports._showCredentials = function (credentials) {
    console.log("turning credentials into string");
    return JSON.stringify ({AccessKeyId: credentials.AccessKeyId, SecretKey: "yeah, right"});
}
