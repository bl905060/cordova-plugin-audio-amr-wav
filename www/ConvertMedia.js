module.exports = {
    record: function(param, successCallback, errorCallback) {
        /*cordova.exec(successCallback,
                     errorCallback,
                     "ConvertMedia",
                     "startRecord",
                     [param]);*/
        alert(1);
    }
    
    stop: function(param, successCallback, errorCallback) {
        /*cordova.exec(successCallback,
                     errorCallback,
                     "ConvertMedia",
                     "stopRecord",
                     [param]);*/
        alert(2);
    }
    
    play: function(audioURL, successCallback, errorCallback) {
        /*cordova.exec(successCallback,
                     errorCallback,
                     "ConvertMedia",
                     "playAudio",
                     [audioURL]);*/
        alert(3);
    }
    
    convertToAmr: function(audioURL, successCallback, errorCallback) {
        /*cordova.exec(successCallback,
                     errorCallback,
                     "ConvertMedia",
                     "convertToAmr",
                     [audioURL]);*/
        alert(4);
    }
};