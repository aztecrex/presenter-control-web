'use strict';

const AWS = require('aws-sdk');
const AWSConfig = require('config/aws-configuration.js')


const config = AWS.config;
config.region = AWSConfig.region;

const cognitoCredentials = new AWS.CognitoIdentityCredentials({
    IdentityPoolId: AWSConfig.poolId
});

const anonymous = function () {
    config.credentials = cognitoCredentials;
}

const loginGoogle = function (token) {
    const newCredentials = new AWS.CognitoIdentityCredentials({
        IdentityPoolId: AWSConfig.poolId
    });
    newCredentials.params.Logins = {};
    newCredentials.params.Logins['accounts.google.com'] = token;
    newCredentials.expired = true;
    config.credentials = newCredentials
    // const googleCreds = new AWS.CognitoIdentityCredentials({
    //     IdentityPoolId: AWSConfig.poolId,
    //     Logins: {
    //         'accounts.google.com': token
    //      }
    // });
    // config.credentials = googleCreds
}

// default is anonymous
anonymous();


exports._anonymous = function() {
    return function() {
        anonymous();
    };
};

exports._login = function (googleToken) {
    return function () {
        loginGoogle(googleToken);
    };
};


exports._identity = function (onError) {
    const credentials = config.credentials;
    return function (onSuccess) {
        return function() {
            credentials.get(function(error) {
                if (error) {
                    onError(error)();
                    return;
                }
                onSuccess(credentials.identityId)();
            });
        };
    };
};


exports._credentials = function (identity) {
    // const params = {
    //     IdentityId: identity
    // };
    const credentials = config.credentials;
    return function(onError) {
        return function (onSuccess) {
            return function() {
                credentials.refresh(function (err) {
                    if (err) {
                        onError(err)();
                        return;
                    }
                    // console.log("identity id: " + credentials.identityId)
                    // console.log("access key id: " + credentials.accessKeyId);
                    // console.log("secret key: " + credentials.secretAccessKey);
                    // console.log("session token:" + credentials.sessionToken);
                    onSuccess(credentials)();
                });
                // const cognitoIdentity = new AWS.CognitoIdentity();
                // cognitoIdentity.getCredentialsForIdentity(params, function(error, data) {
                //     if (error) {
                //         console.log("error obtaining credentials:" + error )
                //         onError(error)();
                //         return;
                //     }
                //     onSuccess(data.Credentials)();
                // });
            };
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

