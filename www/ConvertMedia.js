module.exports = {
    greet: function(name, successCallback, errorCallback) {
        cordova.exec(successCallback,
                     errorCallback,
                     "ConvertMedia",
                     "greet",
                     [name]);
    }
};