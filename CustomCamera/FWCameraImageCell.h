/*!
 @header    UnitCell.h
 @abstract  显示成员的原子View
 @author    丁磊
 @version   1.0.0 2014/05/28 Creation
 */

#import <UIKit/UIKit.h>

@class FWCameraImageCell;

@protocol FWCameraImageCellDelegate<NSObject>

//图片视图被点击
- (void) fwCameraImageCellTouched:(FWCameraImageCell *)cameraImageCell;

//删除按钮被点击
- (void) fwCameraImageCellDeleteButtonTouched:(FWCameraImageCell *)cameraImageCell;

@end

@interface FWCameraImageCell : UIView

@property (nonatomic, assign) BOOL placeholderImageCell;

@property (nonatomic, assign) id<FWCameraImageCellDelegate> delegate;

/*
    method：初始化函数
    frame:坐标
    icon：成员头像
    name：成员名字
 */
- (id)initWithFrame:(CGRect)frame andImage:(UIImage *)image andName:(NSString *)name isPlaceholderImageCell:(BOOL)status;

@end
