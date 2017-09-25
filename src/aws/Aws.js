'use strict';

const AWS = require('aws-sdk');
const AWSConfig = require('config/aws-configuration.js')


const config = AWS.config;
config.region = AWSConfig.region;

const anonymousCredentials = new AWS.CognitoIdentityCredentials({
    IdentityPoolId: AWSConfig.poolId
});

const anonymous = function () {
    config.credentials = anonymousCredentials;
}
// default is anonymous
anonymous();


exports._anonymous = function() {
    return function() {
        anonymous();
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
    const params = {
        IdentityId: identity
    };
    return function(onError) {
        return function (onSuccess) {
            return function() {
                const cognitoIdentity = new AWS.CognitoIdentity();
                cognitoIdentity.getCredentialsForIdentity(params, function(error, data) {
                    if (error) {
                        console.log("error obtaining credentials:" + error )
                        onError(error)();
                        return;
                    }
                    onSuccess(data.Credentials)();
                });
            };
        };
    };
};


exports._fetch = function (name) {
    const fakeContent = "one\ntwo\nthree";
    return function(onError) {
        return function (onSuccess) {
            return function() {
                console.log("DATA: asked for '" + name + "'");
                onSuccess(fakeContent)();
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
                    onSuccess()();
                }
            }
        };
    };
};

