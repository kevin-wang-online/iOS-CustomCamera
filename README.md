# CustomCamera

Cordova-plugin-CustomCamera

基于Cordova Camera插件进行的二次自定义开发。

Cordova-Plugin-Camera插件调用系统的相机功能，拍照界面是基于系统的相机拍摄界面。

Cordova-plugin-CustomCamera采用底层系统API进行图像的采集，对用户使用界面进行进一步的自定义，包含
打开相册以及闪光灯的辅助功能，可以拍摄或采集用户的多张图片，之后通过JS+Cordova完成H5页面与原生插件的数据传输。


JavaScritp调用系统拍照功能

FWCaptureCamera.prototype.scan function (successCallback, errorCallback) {

    //successCallback 成功回调函数
    
    //errorCallback   失败回调函数

}



