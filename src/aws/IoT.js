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
        shadow.subscribe(theTopic)
        cb("connected, subscribed to '" + theTopic + "'");
        if (!registered) {
            shadow.register(thing, {
                persistentSubscribe: true
            });
            cb("registered thing '" + thing + "'");
            registered = true;
        }
    });
    shadow.on('reconnect', function () {
        cb("reconnect")
    });
    shadow.on('message', function (topic, payload) {
        cb("message on '" + topic + "': " + payload.toString())
    });
    shadow.on('delta', function (name, stateObj) {
        cb("delta '" + name + "': " + JSON.stringify(stateObj));
    });
    shadow.on('status', function (name, type, token, stateObj) {
        const prefix = "status " +
              name + ", " +
              type + ", " +
              token + ": "
        cb(prefix + JSON.stringify(stateObj));
    });

    setTimeout( function () {
        const code = shadow.get(thing);
        console.log("GET CODE:" + code);
    }, 3000);
};

const devices = [];

exports._update = function (credentials) {
    return function (onUpdate) {
        return function () {
            devices.push(createDevice(credentials, function (s) {
                onUpdate(s)();
            }));
        };
    };
};

exports._source = function(send) {
    return function () {
        setInterval(function() {
            const now = Date.now();
            console.log ("sending: " + now);
            send(now.toString())();
        }, 4000.0);
        return {};
    };
};

exports.times2 = function(send) {
    return function () {
        setInterval(function() {
            const now = Date.now();
            console.log ("sending: " + now);
            send(now.toString())();
        }, 4000.0);
        return {};
    };
};
