'use strict';

const IOT = require('aws-iot-device-sdk');
const AWSConfig = require('config/aws-configuration.js')

const clientId = function () {
    const min = 100000;
    const max = 999999;
    return "device" + Math.floor(Math.random() * (max - min) + min);
};

const theTopic = "Banana";

var provisionedDevice;
const createDevice = function (credentials, cb) {
    var shadow;
    const thing = 'Slides';
    if (!provisionedDevice) {
        console.log ("creating device");
        var registered = false
        shadow = IOT.thingShadow({
            region: AWSConfig.region,
            host: AWSConfig.host,
            clientId: clientId(),
            protocol: 'wss',
            maximumReconnectTimeMs: 8000,
            debug: true,
            accessKeyId: '',
            secretKey: '',
            sessionToken: ''

            // expired, expireTime, accessKeyId, secretAccessKey, sessionToken, expiryWindow
        });

        shadow.on('connect', function () {
            console.log ("connected ---------------------------------------------------------------- ");
            if (!registered) {
                shadow.register(thing, {
                    persistentSubscribe: true
                });
                console.log("registered '" + thing + "'");
                registered = true;
            } else {
                console.log("already registered '" + thing + "'");
            }
        });
        shadow.on('reconnect', function () {
            console.log("reconnected, registered=" + registered);
            if (!registered) {
                shadow.register(thing, {
                    persistentSubscribe: true
                });
                console.log("registered '" + thing + "'");
                registered = true;
            } else {
                console.log("already registered '" + thing + "'");
            }
        });
        provisionedDevice = shadow;
    } else {
        console.log("reusing device");
        shadow = provisionedDevice;
    }
    console.log("setting creds " + credentials.accessKeyId + " " + credentials.secretAccessKey + " " + credentials.sessionToken + " " + credentials.expireTime)
    shadow.updateWebSocketCredentials(credentials.accessKeyId, credentials.secretAccessKey, credentials.sessionToken, credentials.expireTime)
    return {
        device: shadow,
        thing: thing
    };
};

exports._create = function (credentials) {
    return function () {
        return createDevice(credentials);
    };
};

exports._update = function (device) {
    return function (url) {
        return function (page) {
            return function () {
                const st = {
                    state: {
                        desired: {
                            url: url,
                            page: page
                        }
                    }
                };
                console.log("device: " + JSON.stringify(device))
                device.device.update(device.thing, st);
            };
        };
    };
};
