window.convertmedia = {
    alert: function(title, message, buttonLabel, successCallback) {
        cordova.exec(successCallback,
                     null, // No failure callback
                     "ConvertMedia",
                     "alert",
                     [title, message, buttonLabel]);
    }
};