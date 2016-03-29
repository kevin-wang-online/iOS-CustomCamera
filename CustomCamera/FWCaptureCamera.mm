/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 *
 * Copyright 2015 Martin Reinhardt. All rights reserved.
 * Copyright 2011 Matt Kane. All rights reserved.
 * Copyright (c) 2011, IBM Corporation
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

//------------------------------------------------------------------------------
// use the all-in-one version of zxing that we built
//------------------------------------------------------------------------------

#import <Cordova/CDVPlugin.h>
#import "FWCameraImageView.h"
#import "ZYQAssetPickerController.h"


//------------------------------------------------------------------------------
@class FWCaptureCameraProcessor;
@class FWCaptureCameraViewController;


//------------------------------------------------------------------------------
// 扫码辅助插件类
//------------------------------------------------------------------------------
@interface FWCaptureCamera : CDVPlugin {}

//验证系统框架是否支持AVCaptureSession
- (NSString*)isScanNotPossible;

//调用扫码
- (void)scan:(CDVInvokedUrlCommand*)command;

//调用编码
- (void)encode:(CDVInvokedUrlCommand*)command;

//调用JS成功回调函数
- (void)returnSuccess:(NSString*)scannedText format:(NSString*)format cancelled:(BOOL)cancelled flipped:(BOOL)flipped callback:(NSString*)callback;


//调用JS成功回调函数
- (void)returnSuccess:(NSArray *)captureImageArray cancelled:(BOOL)cancelled callback:(NSString *)callback;


//调用JS失败回调函数
- (void)returnError:(NSString*)message callback:(NSString*)callback;



@end







//------------------------------------------------------------------------------
// 扫码工作核心类
//------------------------------------------------------------------------------
@interface FWCaptureCameraProcessor : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {}

//与js交互插件
@property (nonatomic, retain) FWCaptureCamera*           plugin;

//与js交互回调ID
@property (nonatomic, retain) NSString*                   callback;

//父视图控制器
@property (nonatomic, retain) UIViewController*           parentViewController;

//扫码视图控制器
@property (nonatomic, retain) FWCaptureCameraViewController*        viewController;

//信息采集AVCaptureSession
@property (nonatomic, retain) AVCaptureSession*           captureSession;

//信息采集设备
@property (nonatomic, retain) AVCaptureDevice *           captureDevice;

//信息采集AVCaptureVideoPreviewLayer
@property (nonatomic, retain) AVCaptureVideoPreviewLayer* previewLayer;

//可选的外部样式Xib
@property (nonatomic, retain) NSString*                   alternateXib;

//点击照相按钮，正在拍照片
@property (nonatomic)         BOOL                        isTakingPhoto;

//1D
@property (nonatomic)         BOOL                        is1D;

//2D
@property (nonatomic)         BOOL                        is2D;


@property (nonatomic)         BOOL                        capturing;

//是否是前置摄像头
@property (nonatomic)         BOOL                        isFrontCamera;

//是否翻转
@property (nonatomic)         BOOL                        isFlipped;

//初始化函数：用扫码插件、js交互回调ID、父视图控制器、可选外部样式xib 初始化扫码工作核心类
- (id)initWithPlugin:(FWCaptureCamera*)plugin callback:(NSString*)callback parentViewController:(UIViewController*)parentViewController alterateOverlayXib:(NSString *)alternateXib;

//调用扫码功能
- (void)scanBarcode;

//拍照完成
- (void)barcodeScanSucceeded:(NSArray *)imageArray;

//扫码功能调用失败
- (void)barcodeScanFailed:(NSString*)message;

//扫码功能取消
- (void)barcodeScanCancelled;

//弹出扫码视图控制器
- (void)openDialog;

//设置扫码数据采集器
- (NSString*)setUpCaptureSession;


//AVCaptureVideoDataOutputSampleBufferDelegate 摄像头每获取到一帧的数据返回调用函数一次
- (void)captureOutput:(AVCaptureOutput*)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection*)connection;

//从获取到的采集数据生成照片数据
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;


//保存图片的到设备相册当中
- (void)dumpImage:(UIImage*)image;

@end






//------------------------------------------------------------------------------
// 扫码视图控制器类
//------------------------------------------------------------------------------
@interface FWCaptureCameraViewController : UIViewController <FWCameraImageViewDelegate,ZYQAssetPickerControllerDelegate,UINavigationControllerDelegate> {}

//扫码核心工作类
@property (nonatomic, retain) FWCaptureCameraProcessor*  processor;

//外部的样式布局文件
@property (nonatomic, retain) NSString*        alternateXib;

//存储本地的图片数组
@property (nonatomic, retain) NSMutableArray*  imageArrayBuffer;

//闪光灯是否打开
@property (nonatomic)         BOOL             flashButtonPressed;


@property (nonatomic, retain) FWCameraImageView *fwCameraImageView;

//覆盖视图层
@property (nonatomic, retain) IBOutlet UIView* overlayView;

//拍照按钮
@property (nonatomic, retain) IBOutlet UIButton *takingPhotoButton;

@property (nonatomic, retain) IBOutlet UIButton *cameraFlashButton;

//初始化信息采集视图控制器
- (id)initWithProcessor:(FWCaptureCameraProcessor*)processor alternateOverlay:(NSString *)alternateXib;

//开始信息采集
- (void)startCapturing;

//构造布局视图
- (UIView*)buildOverlayView;

//添加新的图片节点
- (void)addNewFWCaptureCameralImageCell:(UIImage *)image withPhotoType:(UIImagePickerControllerSourceType)sourceType;

//改变拍照按钮的启用与否
- (void)changeTakingPhotoButtonEnabled;

//打开相册按钮绑定事件
- (IBAction)openCameraAlbumButtonPressed:(id)sender;

//拍照按钮绑定事件
- (IBAction)takingPhotoButtonPressed:(id)sender;

//闪光灯按钮绑定事件
- (IBAction)openCameraFlashButtonPressed:(id)sender;

//后退按钮绑定事件
- (IBAction)cancelButtonPressed:(id)sender;

//下一步按钮点击事件
- (IBAction)NextButtonPressed:(id)sender;

@end















//------------------------------------------------------------------------------
// 扫码插件类
//------------------------------------------------------------------------------
@implementation FWCaptureCamera



//--------------------------------------------------------------------------
- (NSString*)isScanNotPossible
{
    NSString* result = nil;
    
    Class aClass = NSClassFromString(@"AVCaptureSession");
    
    if (aClass == nil)
    {
        return @"AVFoundation Framework not available";
    }
    
    return result;
}



//--------------------------------------------------------------------------
- (void)scan:(CDVInvokedUrlCommand*)command {
    FWCaptureCameraProcessor* processor;
    NSString*       callback;
    NSString*       capabilityError;
    
    callback = command.callbackId;
    
    // We allow the user to define an alternate xib file for loading the overlay.
    NSString *overlayXib = nil;
    
    if ( [command.arguments count] >= 1 )
    {
        overlayXib = [command.arguments objectAtIndex:0];
    }
    
    capabilityError = [self isScanNotPossible];
    
    if (capabilityError) {
        [self returnError:capabilityError callback:callback];
        return;
    }
    
    processor = [[FWCaptureCameraProcessor alloc]
                 initWithPlugin:self
                 callback:callback
                 parentViewController:self.viewController
                 alterateOverlayXib:overlayXib
                 ];
    [processor retain];
    [processor retain];
    [processor retain];
    // queue [processor scanBarcode] to run on the event loop
    [processor performSelector:@selector(scanBarcode) withObject:nil afterDelay:0];
}

//--------------------------------------------------------------------------
- (void)encode:(CDVInvokedUrlCommand*)command {
    [self returnError:@"encode function not supported" callback:command.callbackId];
}

//--------------------------------------------------------------------------
- (void)returnSuccess:(NSString*)scannedText format:(NSString*)format cancelled:(BOOL)cancelled flipped:(BOOL)flipped callback:(NSString*)callback{
    NSNumber* cancelledNumber = [NSNumber numberWithInt:(cancelled?1:0)];
    
    NSMutableDictionary* resultDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [resultDict setObject:scannedText     forKey:@"text"];
    [resultDict setObject:format          forKey:@"format"];
    [resultDict setObject:cancelledNumber forKey:@"cancelled"];
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_OK
                               messageAsDictionary: resultDict
                               ];
    
    [self.commandDelegate sendPluginResult:result callbackId:callback];
}

//--------------------------------------------------------------------------
//调用JS成功回调函数
- (void)returnSuccess:(NSArray *)captureImageArray cancelled:(BOOL)cancelled callback:(NSString *)callback
{
    NSNumber *cancelledNumber = [NSNumber numberWithInt:(cancelled?1:0)];
    
    NSMutableArray *imageDataArray = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSInteger index = 0; index < [captureImageArray count]; index ++)
    {
        NSData *imageData = UIImageJPEGRepresentation((UIImage *)[captureImageArray objectAtIndex:index], 0.75);
        
        [imageDataArray addObject:imageData];
    }
    
    NSMutableDictionary* resultDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [resultDict setObject:imageDataArray forKey:@"captureImageArray"];
    [resultDict setObject:cancelledNumber forKey:@"cancelled"];
    
//    CDVPluginResult* result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK
//                                            messageAsDictionary: resultDict];
    CDVPluginResult* result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsMultipart:imageDataArray];
    
    [self.commandDelegate sendPluginResult:result callbackId:callback];
}


//--------------------------------------------------------------------------
- (void)returnError:(NSString*)message callback:(NSString*)callback
{
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_ERROR
                               messageAsString: message
                               ];
    
    [self.commandDelegate sendPluginResult:result callbackId:callback];
}

@end








//------------------------------------------------------------------------------
// 扫码工作核心类
//------------------------------------------------------------------------------
@implementation FWCaptureCameraProcessor

@synthesize plugin               = _plugin;
@synthesize callback             = _callback;
@synthesize parentViewController = _parentViewController;
@synthesize viewController       = _viewController;
@synthesize captureSession       = _captureSession;
@synthesize captureDevice        = _captureDevice;
@synthesize previewLayer         = _previewLayer;
@synthesize alternateXib         = _alternateXib;
@synthesize is1D                 = _is1D;
@synthesize is2D                 = _is2D;
@synthesize capturing            = _capturing;
@synthesize isTakingPhoto        = _isTakingPhoto;

//--------------------------------------------------------------------------
- (id)initWithPlugin:(FWCaptureCamera*)plugin
            callback:(NSString*)callback
parentViewController:(UIViewController*)parentViewController
  alterateOverlayXib:(NSString *)alternateXib {
    self = [super init];
    if (!self) return self;
    
    self.plugin               = plugin;
    self.callback             = callback;
    self.parentViewController = parentViewController;
    self.alternateXib         = alternateXib;
    
    self.is1D      = YES;
    self.is2D      = YES;
    self.capturing = NO;
    self.isTakingPhoto = NO;
    
    return self;
}

//--------------------------------------------------------------------------
- (void)dealloc {
    self.plugin = nil;
    self.callback = nil;
    self.parentViewController = nil;
    self.viewController = nil;
    self.captureSession = nil;
    self.captureDevice = nil;
    self.previewLayer = nil;
    self.alternateXib = nil;
    
    self.capturing = NO;
    self.isTakingPhoto = NO;
    
    [super dealloc];
}

//--------------------------------------------------------------------------
- (void)scanBarcode {
    
    NSString* errorMessage = [self setUpCaptureSession];
    
    if (errorMessage)
    {
        [self barcodeScanFailed:errorMessage];
        
        return;
    }
    
    self.viewController = [[[FWCaptureCameraViewController alloc] initWithProcessor: self alternateOverlay:self.alternateXib] autorelease];
    
    // delayed [self openDialog];
    [self performSelector:@selector(openDialog) withObject:nil afterDelay:1];
}

//--------------------------------------------------------------------------
- (void)openDialog {
    
    [self.parentViewController presentViewController:self.viewController animated: YES completion:nil];
}

//--------------------------------------------------------------------------
- (void)barcodeScanDone {
    self.capturing = NO;
    [self.captureSession stopRunning];
    [self.parentViewController dismissViewControllerAnimated: YES completion:nil];
    
    // viewcontroller holding onto a reference to us, release them so they
    // will release us
    self.viewController = nil;
    
    // delayed [self release];
    [self performSelector:@selector(release) withObject:nil afterDelay:1];
}

//--------------------------------------------------------------------------
- (void)barcodeScanSucceeded:(NSArray *)imageArray
{
    [self barcodeScanDone];
    
    [self.plugin returnSuccess:imageArray cancelled:FALSE callback:self.callback];
}

//--------------------------------------------------------------------------
- (void)barcodeScanFailed:(NSString*)message {
    [self barcodeScanDone];
    //[self.plugin returnError:message callback:self.callback];
}

//--------------------------------------------------------------------------
- (void)barcodeScanCancelled {
    [self barcodeScanDone];
    
    [self.plugin returnSuccess:@"" format:@"" cancelled:TRUE flipped:self.isFlipped callback:self.callback];
    
    if (self.isFlipped) {
        self.isFlipped = NO;
    }
}


- (void)flipCamera
{
    self.isFlipped = YES;
    self.isFrontCamera = !self.isFrontCamera;
    [self performSelector:@selector(barcodeScanCancelled) withObject:nil afterDelay:0];
    [self performSelector:@selector(scanBarcode) withObject:nil afterDelay:0.1];
}

//--------------------------------------------------------------------------
- (NSString*)setUpCaptureSession {
    NSError* error = nil;
    
    AVCaptureSession* captureSession = [[[AVCaptureSession alloc] init] autorelease];
    
    self.captureSession = captureSession;
    
    AVCaptureDevice* __block device = nil;
    
    if (self.isFrontCamera) {
        
        NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        [devices enumerateObjectsUsingBlock:^(AVCaptureDevice *obj, NSUInteger idx, BOOL *stop) {
            if (obj.position == AVCaptureDevicePositionFront) {
                device = obj;
            }
        }];
    } else {
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (!device) return @"unable to obtain video capture device";
        
    }
    
    if (device.isFlashAvailable)
    {
        [device lockForConfiguration:nil];
        [device setFlashMode:AVCaptureFlashModeOff];
        [device unlockForConfiguration];
        
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
        {
            [device lockForConfiguration:nil];
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [device unlockForConfiguration];
        }
    }
    
    //设置当前设备
    self.captureDevice = device;
    
    AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) return @"unable to obtain video capture device input";
    
    AVCaptureVideoDataOutput* output = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    if (!output) return @"unable to obtain video capture output";
    
    
    
    NSDictionary* videoOutputSettings = [NSDictionary
                                         dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                         forKey:(id)kCVPixelBufferPixelFormatTypeKey
                                         ];
    
    output.alwaysDiscardsLateVideoFrames = YES;
    output.videoSettings = videoOutputSettings;
    
    [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    if (![captureSession canSetSessionPreset:AVCaptureSessionPresetMedium]) {
        return @"unable to preset medium quality video capture";
    }
    
    captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    if ([captureSession canAddInput:input]) {
        [captureSession addInput:input];
    }
    else {
        return @"unable to add video capture device input to session";
    }
    
    if ([captureSession canAddOutput:output]) {
        [captureSession addOutput:output];
    }
    else {
        return @"unable to add video capture output to session";
    }
    
    // setup capture preview layer
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    
    // run on next event loop pass [captureSession startRunning]
    [captureSession performSelector:@selector(startRunning) withObject:nil afterDelay:0];
    
    return nil;
}

//--------------------------------------------------------------------------
// this method gets sent the captured frames
//--------------------------------------------------------------------------
- (void)captureOutput:(AVCaptureOutput*)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection*)connection {
    
    if (!self.capturing) return;
    
    //获取到我想要的图片数据
    if (self.isTakingPhoto == YES)
    {
        //用户点击拍照按钮，采集最后图像保存到相册当中
        [self.captureSession stopRunning];
        
        UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
        
        //保存图片到本地相册
        [self dumpImage:image];
        
        if(self.viewController.imageArrayBuffer == nil){
            
            self.viewController.imageArrayBuffer = [[NSMutableArray alloc] init];
            
        }
        
        [self.viewController.imageArrayBuffer addObject:image];
        [self.viewController addNewFWCaptureCameralImageCell:image withPhotoType:UIImagePickerControllerSourceTypeCamera];
        
        self.isTakingPhoto = NO;
        
        [self.captureSession startRunning];
        [self.viewController changeTakingPhotoButtonEnabled];
    }
    else
    {
        
    }
}

/**
 *  从SampleBuffer中获取图片
 *
 *  @param sampleBuffer
 *
 *  @return 从中采集的图片
 */
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    //UIImage *image = [UIImage imageWithCGImage:quartzImage];
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationRight];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

//--------------------------------------------------------------------------
// for debugging
//--------------------------------------------------------------------------
- (void)dumpImage:(UIImage*)image
{
    NSLog(@"writing image to library: %dx%d", (int)image.size.width, (int)image.size.height);
    
    ALAssetsLibrary* assetsLibrary = [[[ALAssetsLibrary alloc] init] autorelease];
    
    [assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage
                                    orientation:ALAssetOrientationUp
                                completionBlock:^(NSURL* assetURL, NSError* error){
                                    if (error)
                                        NSLog(@"   error writing image to library");
                                    else
                                        NSLog(@"   wrote image to library %@", assetURL);
                                }
     ];
}

@end







//------------------------------------------------------------------------------
// 扫码视图控制器类
//------------------------------------------------------------------------------

@implementation FWCaptureCameraViewController

@synthesize processor      = _processor;
@synthesize flashButtonPressed = _flashButtonPressed;
@synthesize alternateXib   = _alternateXib;
@synthesize overlayView    = _overlayView;
@synthesize takingPhotoButton = _takingPhotoButton;
@synthesize cameraFlashButton = _cameraFlashButton;
@synthesize fwCameraImageView = _fwCameraImageView;
@synthesize imageArrayBuffer = _imageArrayBuffer;

//--------------------------------------------------------------------------
- (id)initWithProcessor:(FWCaptureCameraProcessor*)processor alternateOverlay:(NSString *)alternateXib
{
    self = [super init];
    
    if (!self)
        return self;
    
    self.processor = processor;
    self.flashButtonPressed = NO;
    self.alternateXib = alternateXib;
    self.overlayView = nil;
    self.fwCameraImageView = nil;
    self.imageArrayBuffer = nil;
    
    return self;
}

//--------------------------------------------------------------------------
- (void)dealloc
{
    self.view = nil;
    //    self.processor = nil;
    self.flashButtonPressed = NO;
    self.alternateXib = nil;
    self.overlayView = nil;
    self.imageArrayBuffer = nil;
    self.fwCameraImageView = nil;
    
    [super dealloc];
}

//--------------------------------------------------------------------------
- (void)loadView
{
    self.view = [[[UIView alloc] initWithFrame: self.processor.parentViewController.view.frame] autorelease];
    
    // setup capture preview layer
    AVCaptureVideoPreviewLayer* previewLayer = self.processor.previewLayer;
    
    previewLayer.frame = self.view.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    if ([previewLayer.connection isVideoOrientationSupported]) {
        [previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    
    [self.view.layer insertSublayer:previewLayer below:[[self.view.layer sublayers] objectAtIndex:0]];
    
    [self.view addSubview:[self buildOverlayView]];
    
    //加载图片置放视图
    CGFloat cameraViewY = 64 + ScrennWidth;
    CGFloat cameraViewHeight = (ScrennHeight - 64 - ScrennWidth) * 0.45;
    
    CGRect cameraImageViewFrame = CGRectMake(0, cameraViewY, ScrennWidth, cameraViewHeight);
    
    self.fwCameraImageView = [[FWCameraImageView alloc] initWithFrame:cameraImageViewFrame];
    self.fwCameraImageView.delegate = self;
    
    [self.view addSubview:self.fwCameraImageView];
    [self.view bringSubviewToFront:self.fwCameraImageView];
}

//--------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
    
    // set video orientation to what the camera sees
    self.processor.previewLayer.connection.videoOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    // this fixes the bug when the statusbar is landscape, and the preview layer
    // starts up in portrait (not filling the whole view)
    
    self.processor.previewLayer.frame = CGRectMake(0, 64, ScrennWidth, ScrennWidth);
}

//--------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated {
    [self startCapturing];
    
    [super viewDidAppear:animated];
}

//--------------------------------------------------------------------------
- (void)startCapturing {
    self.processor.capturing = YES;
}

//--------------------------------------------------------------------------
- (void)changeTakingPhotoButtonEnabled
{
    if (self.takingPhotoButton.enabled)
    {
        self.takingPhotoButton.enabled = NO;
    }
    else
    {
        self.takingPhotoButton.enabled = YES;
    }
}

//--------------------------------------------------------------------------
//打开相册按钮绑定事件
- (IBAction)openCameraAlbumButtonPressed:(id)sender
{
    //用户点击选择相册图片,则停止摄像头采集图片
    [self.processor.captureSession stopRunning];
    
    ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
    
    picker.maximumNumberOfSelection = 10;
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.showEmptyGroups=NO;
    picker.delegate=self;
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
            NSTimeInterval duration = [[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
            return duration >= 5;
        } else {
            return YES;
        }
    }];
    
    [self presentViewController:picker animated:YES completion:NULL];
}

//--------------------------------------------------------------------------
//拍照按钮绑定事件
- (IBAction)takingPhotoButtonPressed:(id)sender
{
    //拍照按钮点击
    [self.processor setIsTakingPhoto:YES];
    [self changeTakingPhotoButtonEnabled];
}

//--------------------------------------------------------------------------
//闪光灯按钮绑定事件
- (IBAction)openCameraFlashButtonPressed:(id)sender
{
    AVCaptureDevice *device = self.processor.captureDevice;
    
    BOOL enableTorch = self.flashButtonPressed;
    
    if ([device hasTorch] && [device hasFlash])
    {
        [device lockForConfiguration:nil];
        
        if (!enableTorch)
        {
            self.flashButtonPressed = YES;
            [self.cameraFlashButton setBackgroundImage:[UIImage imageNamed:@"CameraFlashBlue.png"] forState:UIControlStateNormal];
            [device setTorchMode:AVCaptureTorchModeOn];
        }
        else
        {
            self.flashButtonPressed = NO;
            [self.cameraFlashButton setBackgroundImage:[UIImage imageNamed:@"CameraFlash.png"] forState:UIControlStateNormal];
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        
        [device unlockForConfiguration];
    }
}

//--------------------------------------------------------------------------
//后退按钮绑定事件
- (IBAction)cancelButtonPressed:(id)sender {
    [self.processor performSelector:@selector(barcodeScanCancelled) withObject:nil afterDelay:0];
}

//--------------------------------------------------------------------------
//下一步按钮点击事件
- (IBAction)NextButtonPressed:(id)sender
{
    if (self.imageArrayBuffer.count == 0 || self.imageArrayBuffer == nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Notice"
                                        message:@"You didn't take any photos,please continue to take photos."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil ] show];
        });
    }
    else
    {
        [self.processor barcodeScanSucceeded:self.imageArrayBuffer];
    }
}

- (void)flipCameraButtonPressed:(id)sender
{
    [self.processor performSelector:@selector(flipCamera) withObject:nil afterDelay:0];
}

//--------------------------------------------------------------------------
- (UIView *)buildOverlayViewFromXib
{
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:self.alternateXib owner:self options:NULL];
    
    
    UIView *layerView = [nibs lastObject];
    
    CGRect bounds = self.view.bounds;
    bounds = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    
    layerView.frame = bounds;
    layerView.autoresizesSubviews = YES;
    layerView.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    layerView.opaque              = NO;
    
    return layerView;
}

//--------------------------------------------------------------------------
- (UIView*)buildOverlayView {
    
    self.alternateXib = @"CameraOverlayView";
    
    if ( nil != self.alternateXib )
    {
        return [self buildOverlayViewFromXib];
    }
    
    return nil;
}

//拍照成功，添加新的显示节点
- (void)addNewFWCaptureCameralImageCell:(UIImage *)image withPhotoType:(UIImagePickerControllerSourceType)sourceType
{
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        //调整方向
        UIImage *newImage = [self correctedImage:image ForCaptureOrientation:UIImageOrientationRight];
        
        //裁剪大小
        UIImage *newImage2 = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([newImage CGImage], CGRectMake(0, 105, ScrennWidth * 2, ScrennWidth * 2))];
        
        [self.fwCameraImageView addNewUnit:newImage2 withName:nil];
    }
    else if(sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
    {
        [self.fwCameraImageView addNewUnit:image withName:nil];
    }
}

- (UIImage *)correctedImage:(UIImage *)image ForCaptureOrientation:(UIImageOrientation)imageOrientation
{
    float rotation_radians = 0;
    bool perpendicular = false;
    
    switch (imageOrientation) {
        case UIImageOrientationUp :
            rotation_radians = 0.0;
            break;
            
        case UIImageOrientationDown:
            rotation_radians = M_PI; // don't be scared of radians, if you're reading this, you're good at math
            break;
            
        case UIImageOrientationRight:
            rotation_radians = M_PI_2;
            perpendicular = true;
            break;
            
        case UIImageOrientationLeft:
            rotation_radians = -M_PI_2;
            perpendicular = true;
            break;
            
        default:
            break;
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Rotate around the center point
    CGContextTranslateCTM(context, image.size.width / 2, image.size.height / 2);
    CGContextRotateCTM(context, rotation_radians);
    
    CGContextScaleCTM(context, 1.0, -1.0);
    float width = perpendicular ? image.size.height : image.size.width;
    float height = perpendicular ? image.size.width : image.size.height;
    CGContextDrawImage(context, CGRectMake(-width / 2, -height / 2, width, height), [image CGImage]);
    
    // Move the origin back since the rotation might've change it (if its 90 degrees)
    if (perpendicular) {
        CGContextTranslateCTM(context, -image.size.height / 2, -image.size.width / 2);
    }
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


#pragma mark -
#pragma mark - FWCameraImageView Delegate

//删除图片节点委托函数
- (void)fwCameraImageViewDidDeleteCameraImageCell:(FWCameraImageView *)cameraImageView withIndexPath:(NSUInteger)indexPath
{
    //对应删除图片数组当中的图片数据
    [self.imageArrayBuffer removeObjectAtIndex:indexPath];
}

#pragma mark -
#pragma makr - ZYQImagePickerController Delegate

-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (int i=0; i<assets.count; i++)
        {
            ALAsset *asset=assets[i];
            
            UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(self.imageArrayBuffer == nil){
                    
                    self.imageArrayBuffer = [[NSMutableArray alloc] init];
                    
                }
                
                [self.imageArrayBuffer addObject:tempImg];
                [self addNewFWCaptureCameralImageCell:tempImg withPhotoType:UIImagePickerControllerSourceTypePhotoLibrary];
                
                self.processor.isTakingPhoto = NO;
                
                [self.processor.captureSession startRunning];
                
                
            });
        }
    });
}

- (void)assetPickerControllerDidCancel:(ZYQAssetPickerController *)picker
{
    [self.processor.captureSession startRunning];
}

@end