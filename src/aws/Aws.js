'use strict';

const AWS = require('aws-sdk');
const AWSConfig = require('config/aws-configuration.js')

const config = AWS.config;
config.region = AWSConfig.region;
config.credentials = new AWS.CognitoIdentityCredentials({
    IdentityPoolId: AWSConfig.poolId
});

// foreign import _authorizeGoogleUser :: forall eff. IdentityToken -> Eff eff Unit
exports._authorizeGoogleUser = function (token) {
    return function() {
        const credentials = config.credentials;
        credentials.Logins = {
            'accounts.google.com': token
        };
        credentials.expired = true;
    };
};


// foreign import _credentials ::
    // forall eff.
    // (Error -> Eff eff Unit)
    // -> (Credentials
    // -> Eff eff Unit)
    // -> Eff eff Unit
exports._credentials = function (onError) {
    return function (onSuccess) {
        return function () {
            const credentials = config.credentials;
            credentials.refresh(function (err) {
                if (err) {
                    onError(err)();
                    return;
                }
                onSuccess(credentials)();
            });
        };
    };
};

const S3 = new AWS.S3();

exports._fetch = function (name) {
    const fakeContent = "one\ntwo\nthree";
    return function(onError) {
        return function (onSuccess) {
            return function() {
                console.log("DATA: asked for '" + name + "'");
                const params = {
                    Bucket: AWSConfig.dataStore,
                    Key: name
                }
                S3.getObject(params, function (err, data) {
                    if (err) {
                        console.log ("FETCH ERROR: " + err);
                        onError(err)();
                        return;
                    }
                    console.log("BODY: " + data.Body);
                    onSuccess(data.Body.toString())();
                });
            };
        };
    };
};

exports._save = function (name) {
    return function (content) {
        return function (onError) {
            return function (onSuccess) {
                return function() {
                    console.log("DATA: saving '" + content + "' under '" + name + "'");
                        const params = {Body: content,
                        Bucket: AWSConfig.dataStore,
                        Key: name,
                    }
                    S3.putObject(params, function (err, data) {
                        if (err) {
                            onError(err)();
                        }
                        onSuccess({})();
                    });
                }
            }
        };
    };
};

