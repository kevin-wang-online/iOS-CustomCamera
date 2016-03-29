/*!
 @header    UnitView.h
 @abstract  添加成员animationView
 @author    丁磊
 @version   1.0.0 2014/05/28 Creation
 */

#import <UIKit/UIKit.h>

@class FWCameraImageView;

@protocol FWCameraImageViewDelegate<NSObject>

//图片视图删除委托
- (void) fwCameraImageViewDidDeleteCameraImageCell:(FWCameraImageView *)cameraImageView withIndexPath:(NSUInteger)indexPath;

@end

@interface FWCameraImageView : UIView

@property (nonatomic, assign) id<FWCameraImageViewDelegate> delegate;

/*
    添加一个成员
    image： 图像
    name：  名字
 */
- (void)addNewUnit:(UIImage *)image withName:(NSString *)name;

@end
