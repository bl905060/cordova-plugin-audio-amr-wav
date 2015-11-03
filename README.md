##cordova-plugin-audio-amr-wav

**Cordova / PhoneGap 录音插件**：具备录制并播放WAV格式功能，同时提供AMR与WAV相互转换功能

## 安装

#### 从Github安装最新版本

```
cordova plugin add https://github.com/bl905060/cordova-plugin-audio-amr-wav.git
```

## 使用

### 录制

##### 1、开始录制

```js
recordAudio.record();
```
##### 2、停止录制

```js
//使用成功回调函数
recordAudio.stop(recordSucess);

//成功回调函数中会包含录制文件的全路径、持续时间以及文件名
function recordSucess(results) {
    //全路径以"file://"为前缀，返回amr格式的路径，同时保留wav格式的文件
    alert(results.fullPath);
    //持续时间以秒为单位，并向下取整
    alert(results.duration);
    //传回文件名
    alert(results.voiceID);
}
```

### 播放

```js
//传入amr格式文件的全路径，播放之前先将amr格式转换为wav格式并开始播放wav文件，同时保留amr格式文件
recordAudio.play(audioURL);
```

### WAV转AMR

```js
//传入wav文件全路径，并使用成功回调函数
recordAudio.convertToAmr(audioURL, convertSuccess);

//成功回调函数中会包含录制文件的全路径、持续时间以及文件名
function convertSuccess(results) {
    //全路径以"file://"为前缀，返回amr格式的路径，同时保留wav格式的文件
    alert(results.fullPath);
    //持续时间以秒为单位，并向下取整
    alert(results.duration);
    //传回文件名
    alert(results.voiceID);
}
```

### AMR转WAV

```js
//传入wav文件全路径，并使用成功回调函数
recordAudio.convertToWav(audioURL, convertSuccess);

//成功回调函数中会包含录制文件的全路径、持续时间以及文件名
function convertSuccess(results) {
    //全路径以"file://"为前缀，返回amr格式的路径，同时保留wav格式的文件
    alert(results.fullPath);
    //持续时间以秒为单位，并向下取整
    alert(results.duration);
    //传回文件名
    alert(results.voiceID);
}
```

## 完整案例

```js
//控件触碰开始时进行录音
document.getElementById("recorder").addEventListener('touchstart', function() {
    recordAudio.record();
}, false);

//控件触碰结束时停止录音 
document.getElementById("recorder").addEventListener('touchend', function() {
    recordAudio.stop(recordSucess);
 
    function recordSucess(results) {
        alert(results.fullPath);
        alert(results.duration);
        alert(results.voiceID);
    }
}, false);

//控件触碰开始时播放录音
document.getElementById("player").addEventListener('touchstart', function() {
    var audioURL = document.getElementById("audioURL").value;
    recordAudio.play(audioURL);
}, false);

//控件触碰开始时将wav文件转换为amr文件
document.getElementById("convertToAmr").addEventListener('touchstart', function() {
    var audioURL = document.getElementById("audioURL").value;
    recordAudio.convertToAmr(audioURL, convertSuccess);
 
    function convertSuccess(results) {
        alert(results.fullPath);
        alert(results.duration);
        alert(results.voiceID);
    }
}, false);

//控件触碰开始时将amr文件转换为wav文件
document.getElementById("convertToWav").addEventListener('touchstart', function() {
    var audioURL = document.getElementById("audioURL").value;
    recordAudio.convertToWav(audioURL, convertSuccess);
    
    function convertSuccess(results) {
        alert(results.fullPath);
        alert(results.duration);
        alert(results.voiceID);
    }
}, false);
```

## 平台支持

iOS (7+) only.
