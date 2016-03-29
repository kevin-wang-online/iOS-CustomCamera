/*!
 @header    UnitCell.m
 @abstract  显示成员的原子View
 @author    丁磊
 @version   1.0.0 2014/05/28 Creation
 */

#import "FWCameraImageCell.h"

#define FWCameraImageDeleteButtonSize 23

@interface FWCameraImageCell ()

// user的头像url
@property (nonatomic, strong) UIImage *cellImage;

// user的名称
@property (nonatomic, strong) NSString *name;

@end

@implementation FWCameraImageCell

- (id)initWithFrame:(CGRect)frame andImage:(UIImage *)image andName:(NSString *)name isPlaceholderImageCell:(BOOL)status
{
    _cellImage = image;
    _name = name;
    _placeholderImageCell = status;
    self = [super initWithFrame:frame];
    if (self) {
        [self setProperty];
    }
    return self;
}

/*
 *@method 设置UnitCell的属性
 */
- (void)setProperty
{
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat imageViewPosition = 0;
    CGFloat imageViewSize = self.bounds.size.width;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageViewPosition, imageViewPosition, imageViewSize, imageViewSize)];
    
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setImage:_cellImage];
    imageView.layer.cornerRadius = 10;
    imageView.clipsToBounds = YES;
    
    [self addSubview:imageView];
    
    if (!_placeholderImageCell)
    {
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [deleteButton setFrame:CGRectMake(self.bounds.size.width - FWCameraImageDeleteButtonSize / 2.0, - FWCameraImageDeleteButtonSize / 2.0, FWCameraImageDeleteButtonSize, FWCameraImageDeleteButtonSize)];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"CameraDeleteButton"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(fwCaptureCameraImageCellDeleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *assistantButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [assistantButton setFrame:CGRectMake(imageViewSize * 0.65, 0, imageViewSize * 0.35, imageViewSize * 0.35)];
        [assistantButton setBackgroundColor:[UIColor clearColor]];
        [assistantButton addTarget:self action:@selector(fwCaptureCameraImageCellDeleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:deleteButton];
        [self addSubview:assistantButton];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] init];
        
        [singleTap addTarget:self action:@selector(fwCaptureCameraImageCellClicked:)];
        
        [self addGestureRecognizer:singleTap];
    }
    else
    {
        imageView.layer.borderWidth = 1.0;
        imageView.layer.borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1].CGColor;
    }
}

#pragma mark -
#pragma mark - Private Methods Related Delegate Methods

//图片视图点击响应事件
-(void)fwCaptureCameraImageCellClicked:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(fwCameraImageCellTouched:)])
        [_delegate fwCameraImageCellTouched:self];
}

//删除按钮点击响应事件
- (void)fwCaptureCameraImageCellDeleteButtonClicked:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(fwCameraImageCellDeleteButtonTouched:)])
        [_delegate fwCameraImageCellDeleteButtonTouched:self];
}

@end
