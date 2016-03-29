/*!
 @header    FWCameraImageView.m
 @author    Kevin
 @version   1.0.0 2015/10/29 Creation
 */

#import "FWCameraImageView.h"
#import "FWCameraImageCell.h"

#define defaultWidth  self.bounds.size.height * 0.7      // 每一个unitCell的默认宽度
#define defaultYPostion self.bounds.size.height * 0.15
#define defaultPace   10       // unitCell之间的间距
#define duration      0.5     // 动画执行时间
#define defaultVisibleCount 4 //默认显示的unitCell的个数

@interface FWCameraImageView ()<FWCameraImageCellDelegate, UIScrollViewDelegate>

/*
 @abstract 用于显示成员
 */

@property (nonatomic, strong) UIScrollView   *scrollView;

/*
   @abstract 用于管理成员
 */
@property (nonatomic, strong) NSMutableArray *unitList;

/*
   @abstract 默认显示的占位图
 */
@property (nonatomic, strong) FWCameraImageCell *defaultUnit;

@property (nonatomic, strong) FWCameraImageCell *defaultUnit1;
@property (nonatomic, strong) FWCameraImageCell *defaultUnit2;
@property (nonatomic, strong) FWCameraImageCell *defaultUnit3;
@property (nonatomic, strong) FWCameraImageCell *defaultUnit4;

@property (nonatomic, assign) NSInteger     numberOfDefaultUnit;

/*
   @abstract 判断是否有删除操作
 */
@property (nonatomic, assign) BOOL           hasDelete;

/*
   @abstract 判断删除操作unitCell的移动方向
 */
@property (nonatomic, assign) BOOL           frontMove;

/*
   @abstract 统计删除操作总共移动的次数
 */
@property (nonatomic, assign) int            moveCount;

@end

@implementation FWCameraImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setProperty];
    }
    return self;
}
/*
 *   @method
 *   @function
 *   初始化_scrollView等
 */
- (void) setProperty
{
    _unitList = [[NSMutableArray alloc] init];
    _hasDelete = NO;
    _moveCount = 0;
    
    _numberOfDefaultUnit = 5;
    
    _scrollView = [[UIScrollView alloc] init];
    
    _scrollView.delegate = self;
    _scrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.scrollEnabled = YES;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = YES;
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    _scrollView.contentSize = [self contentSizeForUIScrollView:0];
    
    [self addSubview:_scrollView];
    
    _defaultUnit = [[FWCameraImageCell alloc] initWithFrame:CGRectMake( defaultPace, defaultYPostion, defaultWidth, defaultWidth) andImage:[UIImage imageNamed:@"CameraCaptureDefault.png"] andName:nil isPlaceholderImageCell:YES];
    
    _defaultUnit1 = [[FWCameraImageCell alloc] initWithFrame:CGRectMake( 2 * defaultPace + defaultWidth, defaultYPostion, defaultWidth, defaultWidth) andImage:[UIImage imageNamed:@"CameraCaptureDefault.png"] andName:nil isPlaceholderImageCell:YES];
    _defaultUnit2 = [[FWCameraImageCell alloc] initWithFrame:CGRectMake( 3 * defaultPace + 2 * defaultWidth, defaultYPostion, defaultWidth, defaultWidth) andImage:[UIImage imageNamed:@"CameraCaptureDefault.png"] andName:nil isPlaceholderImageCell:YES];
    _defaultUnit3 = [[FWCameraImageCell alloc] initWithFrame:CGRectMake( 4 * defaultPace + 3 * defaultWidth, defaultYPostion, defaultWidth, defaultWidth) andImage:[UIImage imageNamed:@"CameraCaptureDefault.png"] andName:nil isPlaceholderImageCell:YES];
    _defaultUnit4 = [[FWCameraImageCell alloc] initWithFrame:CGRectMake( 5 * defaultPace + 4 * defaultWidth, defaultYPostion, defaultWidth, defaultWidth) andImage:[UIImage imageNamed:@"CameraCaptureDefault.png"] andName:nil isPlaceholderImageCell:YES];
    
    [_scrollView addSubview:_defaultUnit];
    [_scrollView addSubview:_defaultUnit1];
    [_scrollView addSubview:_defaultUnit2];
    [_scrollView addSubview:_defaultUnit3];
    [_scrollView addSubview:_defaultUnit4];
    
    [self scrollViewAbleScrollWithNumbr:_numberOfDefaultUnit];
}

/*
 *  @method
 *  @function
 *  根据index获取UIScrollView的ContentSize
 */
- (CGSize)contentSizeForUIScrollView:(NSInteger)index
{
    float width = (defaultPace + defaultWidth) * index;
    if (width < _scrollView.bounds.size.width)
        width = _scrollView.bounds.size.width;
    return CGSizeMake(width, defaultWidth);
}

/*
 *  @method
 *  @function
 *  根据_unitList.count
 *  设置scrollView是否可以滚动
 *  设置scrollView的ContentSize
 *  设置scrollView的VisibleRect
 */
- (void)scrollViewAbleScrollWithNumbr:(NSInteger)count
{
//    _scrollView.scrollEnabled = (((_unitList.count + 1) * (defaultPace + defaultWidth)) > _scrollView.frame.size.width) ? YES : NO;
      _scrollView.contentSize = [self contentSizeForUIScrollView:(_unitList.count + count)];
    
    if (count == 5)
    {
        
    }
    else
    {
        [_scrollView scrollRectToVisible:CGRectMake(_scrollView.contentSize.width - defaultWidth, 0, defaultWidth, self.frame.size.height) animated:YES];
    }
    
}

/*
 *  @method
 *  @function
 *  新增一个unitCell
 *  _defaultUnit向后移动并伴随动画效果
 *  newUnitCell渐变显示
 */
- (void)addNewUnit:(UIImage *)image withName:(NSString *)name
{
    __block FWCameraImageCell *newUnitCell;
    
    CGFloat x = (_unitList.count) * (defaultPace + defaultWidth) + defaultPace;
    
    newUnitCell = [[FWCameraImageCell alloc] initWithFrame:CGRectMake(x, defaultYPostion, defaultWidth, defaultWidth) andImage:image andName:name isPlaceholderImageCell:NO];
    
    newUnitCell.alpha = 0.1;
    newUnitCell.delegate = self;
    
    [_unitList addObject:newUnitCell];
    
    [_scrollView addSubview:newUnitCell];
    
    _numberOfDefaultUnit = _numberOfDefaultUnit - 1;
    
    if (_numberOfDefaultUnit < 0) {
        _numberOfDefaultUnit = 0;
    }
    
    switch (_numberOfDefaultUnit) {
        case 0:
            [_defaultUnit4 removeFromSuperview];
        break;
        case 1:
            [_defaultUnit3 removeFromSuperview];
        break;
        case 2:
            [_defaultUnit2 removeFromSuperview];
        break;
        case 3:
            [_defaultUnit1 removeFromSuperview];
        break;
        case 4:
            [_defaultUnit removeFromSuperview];
        break;
        default:
        break;
    }
    
    [self scrollViewAbleScrollWithNumbr:_numberOfDefaultUnit];
    
    _defaultUnit.alpha = 0.5;

    [UIView animateWithDuration:duration animations:^(){
        CGRect rect = _defaultUnit.frame;
        rect.origin.x += (defaultPace + defaultWidth);
        _defaultUnit.frame = rect;
        _defaultUnit.alpha = 1.0;
        newUnitCell.alpha = 0.8;

    } completion:^(BOOL finished){
        newUnitCell.alpha = 1.0;

    }];

}



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    [self isNeedResetFrame];
}

/*
 *  @method
 *  @function
 *  当删除操作是前面的unitCell向后移动时
 *  做滚动操作或者添加操作需要重新设置每个unitCell的frame
 */
- (void)isNeedResetFrame
{
    if (_frontMove && _moveCount > 0) {

        for (int i = 0; i < _unitList.count; i++) {
            FWCameraImageCell *cell = [_unitList objectAtIndex:(NSUInteger) i];
            CGRect rect = cell.frame;
            rect.origin.x -= (defaultPace + defaultWidth) * _moveCount;
            cell.frame = rect;
        }

        CGRect rect = _defaultUnit.frame;
        rect.origin.x -= (defaultPace + defaultWidth) * _moveCount;
        _defaultUnit.frame = rect;

        _frontMove = NO;
        _moveCount = 0;
    }

    if (_hasDelete)
    {
        _scrollView.contentSize = [self contentSizeForUIScrollView:(_unitList.count + _numberOfDefaultUnit)];
        _hasDelete = !_hasDelete;
    }
}

#pragma mark -
#pragma mark - FWCameraImageCell Delegate

//点击视图的委托事件
- (void)fwCameraImageCellTouched:(FWCameraImageCell *)cameraImageCell
{
    
}

//点击删除按钮的委托
- (void)fwCameraImageCellDeleteButtonTouched:(FWCameraImageCell *)cameraImageCell
{
    _hasDelete = YES;
    
    NSInteger index = (NSInteger)[_unitList indexOfObject:cameraImageCell];
    
    // step_1: 设置相关unitCell的透明度
    cameraImageCell.alpha = 0.8;
    
    // 判断其余cell的移动方向（从前向后移动/从后向前移动）
    _frontMove = NO;
    if (_unitList.count - 1 > defaultVisibleCount
        && (_unitList.count - index - 1) <= defaultVisibleCount) {
        _frontMove = YES;
    }
    if (index == _unitList.count - 1 && !_frontMove)
        _defaultUnit.alpha = 0.5;
    
    [UIView animateWithDuration:duration animations:^(){
        
        // step_2: 其余unitCell依次移动
        if (_frontMove)
        {
            // 前面的向后移动
            for (NSInteger i = 0; i < index; i++) {
                FWCameraImageCell *cell = [_unitList objectAtIndex:(NSUInteger) i];
                CGRect rect = cell.frame;
                rect.origin.x += (defaultPace + defaultWidth);
                cell.frame = rect;
            }
            _moveCount++;
        }
        else
        {
            // 后面的向前移动
            for (NSInteger i = index + 1; i < _unitList.count; i++) {
                FWCameraImageCell *cell = [_unitList objectAtIndex:(NSUInteger)i];
                CGRect rect = cell.frame;
                rect.origin.x -= (defaultPace + defaultWidth);
                cell.frame = rect;
            }
            
            // step_3: _defaultUnit向前移动
            CGRect rect = _defaultUnit.frame;
            rect.origin.x -= (defaultPace + defaultWidth);
            _defaultUnit.frame = rect;
            _defaultUnit.alpha = 1.0;
            
        }
        cameraImageCell.alpha = 0.0;
        
    } completion:^(BOOL finished){
        
        // step_4: 删除被点击的unitCell
        [cameraImageCell removeFromSuperview];
        [_unitList removeObject:cameraImageCell];
        
        if (_unitList.count <= defaultVisibleCount)
            [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
        if (_frontMove) {
            [self isNeedResetFrame];
        }
    }];
    
    if(_delegate && [_delegate respondsToSelector:@selector(fwCameraImageViewDidDeleteCameraImageCell:withIndexPath:)])
    {
        [_delegate fwCameraImageViewDidDeleteCameraImageCell:self withIndexPath:index];
    }
    
}


@end
