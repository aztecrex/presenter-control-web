'use strict';

const LoadGoogleAPI = require('load-google-api');

const params = {
    clientId: "64025738448-fj1tgig9cs4smtvralq068tbhqabvc8o.apps.googleusercontent.com",
    scope: [
      "profile"
    ]
  };

const loader = new LoadGoogleAPI(params);


const withAuth = (function () {
    var auth;
    return function (f) {
        if (auth)
            f(auth);
        else {
            loader.loadGoogleAPI().then(function() {
                loader.init().then(function () {
                    auth = window.gapi.auth2.getAuthInstance();
                    console.log("google auth loaded");
                    f(auth);
                });
            });
        }
    }
})();

exports._updates = function (onUpdate) {
    return function () {
        withAuth(function (auth) {
            function emit() {
                const user = auth.currentUser.get();
                const status = user.hasGrantedScopes('profile') === true;
                var event = { authorized: status };
                if (status) {
                    const profile = user.getBasicProfile();
                    event.id = profile.getId();
                    event.name = profile.getName();
                    event.token = user.getAuthResponse().id_token;
                    event.email = profile.getEmail();
                }
                onUpdate(event)();
            }
            auth.isSignedIn.listen(emit);
            emit();
        });
    };
};

exports._updName = function (u) { return u.name; };
exports._updEmail = function (u) { return u.email; };
exports._updToken = function (u) { return u.token; };
exports._updAuthorized = function (u) { return u.authorized; };

// exports._initialize = function (onSuccess) {
//     return function () {
//         loader.loadGoogleAPI().then(function () {
//             loader.init().then(function () {
//                 auth = window.gapi.auth2.getAuthInstance();
//                 showSigninStatus();
//                 auth.isSignedIn.listen(showSigninStatus);
//                 onSuccess()();
//             });
//         });
//         return {};
//     };
// };


// exports._attachLogin = function (onError) {
//     return function (onSuccess) {
//         return function (elementId) {
//             return function () {
//                 auth.attachClickHandler(
//                     'login', {scope: "profile"}, showSigninStatus, showError
//                 );
//             };
//         };
//     };
// };


// contacts.loadGoogleAPI().then(() => {
//     contacts.init().then(() => {
//       window.auth = window.gapi.auth2.getAuthInstance();
//       auth.isSignedIn.listen(updateSignInStatus);
//     }).then(() => {
//       main();
//     });
//   })
