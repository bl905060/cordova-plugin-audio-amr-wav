module.exports = {
    //fullPath : '',
    
    //duration : '',
    
    //record: function(param, successCallback, errorCallback)
    record: function(param, successCallback, errorCallback) {
        cordova.exec(successCallback,
                     errorCallback,
                     "recordAudio",
                     "startRecord",
                     []);
        
        /*function successCallback() {
            
        }
        
        function errorCallback() {
            
        }*/
    },
    
    //stop: function(param, successCallback, errorCallback)
    stop: function(successCallback, errorCallback) {
        cordova.exec(successCallback,
                     errorCallback,
                     "recordAudio",
                     "stopRecord",
                     []);
        
        /*function successCallback(results) {
            fullPath = results.fullPath;
            duration = results.duration;
            //alert(fullPath);
            //alert(duration);
        }
        
        function errorCallback(error) {
            console.log(error);
        }*/
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