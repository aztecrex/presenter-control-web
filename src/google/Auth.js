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

exports._identityToken = function (onError) {
    return function (onSuccess) {
        return function() {
            withAuth(function (auth) {
                const user = auth.currentUser.get();
                const status = user.hasGrantedScopes('profile') === true;
                if (status) {
                    console.log("google user is authorized")
                    onSuccess(user.getAuthResponse().id_token)();
                } else {
                    console.log("google user is not authorized")
                    onError(new Error("not logged in"))();
                }
            });
            return {};
        };
    };
};

exports._showIdentityToken = function (token) { return token; }

exports._logout = function() {
    withAuth(function (auth) {
        auth.signOut();
    });
    return {};
}

// exports._updates = function (onUpdate) {
//     return function () {
//         withAuth(function (auth) {
//             function emit() {
//                 const user = auth.currentUser.get();
//                 const status = user.hasGrantedScopes('profile') === true;
//                 var event = { authorized: status };
//                 if (status) {
//                     const profile = user.getBasicProfile();
//                     event.id = profile.getId();
//                     event.name = profile.getName();
//                     event.token = user.getAuthResponse().id_token;
//                     event.email = profile.getEmail();
//                 }
//                 onUpdate(event)();
//             }
//             auth.isSignedIn.listen(emit);
//             emit();
//             setTimeout(function () {
//                 emit();
//             },500);
//         });
//     };
// };

