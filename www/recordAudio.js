module.exports = {
    
    record: function(handler1, handler2, handler3) {
        var fileName;
        var flag = 0;
        if (typeof(handler1) !== "string") {
            fileName = undefined;
            flag = 1;
        }
        else {
            fileName = handler1;
        }
        
        cordova.exec(successHandler,
                     errorHandler,
                     "recordAudio",
                     "startRecord",
                     [fileName]);
        
        function successHandler(results) {
            if (flag && (typeof(handler1) === "function")) {
                handler1(results);
            }
            else if ((typeof(handler2) === "function")) {
                handler2(results);
            }
        }
        
        function errorHandler(results) {
            if (flag) {
                handler2(results);
            }
            else {
                handler3(results);
            }
        }
    },
    
    stop: function(successCallback, errorCallback) {
        cordova.exec(successCallback,
                     errorCallback,
                     "recordAudio",
                     "stopRecord",
                     []);
    },
    
    play: function(audioURL, successCallback, errorCallback) {
        cordova.exec(successCallback,
                     errorCallback,
                     "recordAudio",
                     "playAudio",
                     [audioURL]);
    },
    
    convertToAmr: function(audioURL, successCallback, errorCallback) {
        cordova.exec(successCallback,
                     errorCallback,
                     "recordAudio",
                     "convertToAmr",
                     [audioURL]);
    },
    
    convertToWav: function(audioURL, successCallback, errorCallback) {
        cordova.exec(successCallback,
                     errorCallback,
                     "recordAudio",
                     "convertToWav",
                     [audioURL]);
    },
    
    deleteAudio: function(audioURL, successCallback, errorCallback) {
        cordova.exec(successCallback,
                     errorCallback,
                     "recordAudio",
                     "deleteAudio",
                     [audioURL]);
    }
};