module.exports = {
    fullPath : '',
    
    duration : '',
    
    //record: function(param, successCallback, errorCallback)
    record: function(param, successCallback, errorCallback) {
        cordova.exec(successCallback,
                     errorCallback,
                     "ConvertMedia",
                     "startRecord",
                     []);
        
        /*function successCallback() {
            
        }
        
        function errorCallback() {
            
        }*/
    },
    
    //stop: function(param, successCallback, errorCallback)
    stop: function() {
        cordova.exec(successCallback,
                     errorCallback,
                     "ConvertMedia",
                     "stopRecord",
                     []);
        
        function successCallback(results) {
            fullPath = results.fullPath;
            duration = results.duration;
            //alert(fullPath);
            //alert(duration);
        }
        
        function errorCallback(error) {
            console.log(error);
        }
        
        console.log(fullPath);
        console.log(duration);
    },
    
    play: function(audioURL, successCallback, errorCallback) {
        cordova.exec(successCallback,
                     errorCallback,
                     "ConvertMedia",
                     "playAudio",
                     [audioURL]);
    },
    
    convertToAmr: function(audioURL, successCallback, errorCallback) {
        cordova.exec(successCallback,
                     errorCallback,
                     "ConvertMedia",
                     "convertToAmr",
                     [audioURL]);
    },
    
    convertToWav: function(audioURL, successCallback, errorCallback) {
        cordova.exec(successCallback,
                     errorCallback,
                     "ConvertMedia",
                     "convertToWav",
                     [audioURL]);
    }
};