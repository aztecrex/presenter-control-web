'use strict';

const IOT = require('aws-iot-device-sdk');
const AWSConfig = require('config/aws-configuration.js')

const clientId = function () {
    const min = 100000;
    const max = 999999;
    return "device" + Math.floor(Math.random() * (max - min) + min);
};

const theTopic = "Banana";

const createDevice = function (credentials, cb) {
    const thing = 'Slides';
    var registered = false
    const shadow = IOT.thingShadow({
        region: AWSConfig.region,
        host: AWSConfig.host,
        clientId: clientId(),
        protocol: 'wss',
        maximumReconnectTimeMs: 8000,
        debug: true,
        accessKeyId: credentials.AccessKeyId,
        secretKey: credentials.SecretKey,
        sessionToken: credentials.SessionToken
    });
    shadow.on('connect', function () {
        if (!registered) {
            shadow.register(thing, {
                persistentSubscribe: true
            });
            console.log ("connected");
            registered = true;
        }
    });
    shadow.on('reconnect', function () {
        console.log("reconnected")
    });

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
