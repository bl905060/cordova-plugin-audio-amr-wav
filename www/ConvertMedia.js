module.exports = {
    //fullPath : '',
    
    //duration : '',
    
    //record: function(param, successCallback, errorCallback)
    record: function() {
        cordova.exec(successCallback,
                     errorCallback,
                     "ConvertMedia",
                     "startRecord",
                     []);
        
        function successCallback() {
            
        }
        
        function errorCallback() {
            
        }
    },
    
    //stop: function(param, successCallback, errorCallback)
    stop: function() {
        cordova.exec(successCallback,
                     errorCallback,
                     "ConvertMedia",
                     "stopRecord",
                     []);
        
        function successCallback(result) {
            fullPath = result.fullPath;
            duration = result.duration;
        }
        
        function errorCallback(error) {
            console.log(error);
        }
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
    }
    
    convertToWav: function(audioURL, successCallback, errorCallback) {
        cordova.exec(successCallback,
                     errorCallback,
                     "ConvertMedia",
                     "convertToWav",
                     [audioURL]);
    }
};