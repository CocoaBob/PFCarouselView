//
//  PFCarouselView.m
//  PFCarouselView
//
//  Created by PFei_He on 14-10-24.
//  Copyright (c) 2014年 PF-Lib. All rights reserved.
//
//  https://github.com/PFei-He/PFCarouselView
//
//  vesion: v0.4.0
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PFCarouselView.h"

@interface NSTimer (PFCarouselView)

/**
 *  @brief 暂停计时器
 */
- (void)pauseTimer;

/**
 *  @brief 恢复计时器
 */
- (void)resumeTimer;

/**
 *  @brief 恢复计时器的间隔时长
 */
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)timeInterval;

@end

@implementation NSTimer (PFCarouselView)

//暂停计时器
- (void)pauseTimer
{
    //假如计时器无效则返回
    if (![self isValid]) return;

    //设置计时器运行时间为未来时间，则暂停了计时器
    [self setFireDate:[NSDate distantFuture]];
}

//恢复计时器
- (void)resumeTimer
{
    //假如计时器无效则返回
    if (![self isValid]) return;

    //设置计时器运行时间为当前时间，则立即运行计时器
    [self setFireDate:[NSDate date]];
}

//恢复计时器的时间间隔
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)timeInterval
{
    //假如计时器无效则返回
    if (![self isValid]) return;

    //设置计时器运行时间为指定的间隔时长
    [self setFireDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]];
}

@end

//获取总页数
typedef NSInteger (^numberOfPagesBlock)(PFCarouselView *);

//获取内容页
typedef UIView *(^contentViewBlock)(PFCarouselView *, NSInteger);

//页控制器（白点）
typedef void (^pageControlBlock)(PFCarouselView *, UIPageControl *, NSInteger);

//文本
typedef void (^textLabelBlock)(PFCarouselView *, UILabel *, NSInteger);

//点击事件
typedef void (^tapBlock)(PFCarouselView *, NSInteger);

@interface PFCarouselView () <UIScrollViewDelegate>
{
    NSInteger       currentPage;   //当前页的序号
    NSInteger       pagesCount;         //总页数
    NSMutableArray  *contentViews;      //内容视图
    NSTimer         *animationTimer;    //动画计时器

    CGPoint         pageControlCenter;  //页控制器坐标
    CGRect          textLabelFrame;     //文本尺寸
}

///滚动视图
@property (nonatomic, strong)   UIScrollView                *scrollView;

///时间间隔
@property (nonatomic, assign)   NSTimeInterval              animationDuration;

///获取页数
@property (nonatomic, copy)     numberOfPagesBlock          numberOfPagesBlock;

///内容视图
@property (nonatomic, copy)     contentViewBlock            contentViewBlock;

///页控制器（白点）
@property (nonatomic, copy)     pageControlBlock            pageControlBlock;

///文本
@property (nonatomic, copy)     textLabelBlock              textLabelBlock;

///点击事件
@property (nonatomic, copy)     tapBlock                    tapBlock;

///代理
@property (nonatomic, weak)     id<PFCarouselViewDelegate>  delegate;

@end

@implementation PFCarouselView

- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration delegate:(id<PFCarouselViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        //代理
        if (delegate) self.delegate = delegate, delegate = nil;

        //滚动视图
        [self setupScrollView];

        //页控制器（白点）
        _pageControlShow = YES;
        [self setupPageControl];

        //文本
        _textLabelShow = YES;
        [self setupTextLabel];
        
        //计时器
        [self setupAnimationTimerWithDuration:self.animationDuration = animationDuration];
    }
    return self;
}

#pragma mark - Views Management

//设置滚动视图
- (void)setupScrollView
{
    //滚动视图
    if (!_scrollView) _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.autoresizingMask = 0xFF;
    _scrollView.contentMode = UIViewContentModeCenter;
    _scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame));
    _scrollView.delegate = self;
    _scrollView.contentOffset = CGPointMake(CGRectGetWidth(_scrollView.frame), 0);
    _scrollView.pagingEnabled = YES;
    [self addSubview:_scrollView];
}

//设置页控制器（白点）
- (void)setupPageControl
{
    //页控制器（白点）
    if (!_pageControl) _pageControl = [[UIPageControl alloc] init];
    pageControlCenter.x ? (_pageControl.center = pageControlCenter) : (_pageControl.center = CGPointMake(_scrollView.center.x, _scrollView.bounds.size.height - 40));
    [self addSubview:_pageControl];
}

//设置文本
- (void)setupTextLabel
{
    //文本
    if (!_textLabel) _textLabel = [[UILabel alloc] init];
    textLabelFrame.size.height ? (_textLabel.frame = textLabelFrame) : (_textLabel.frame = CGRectMake(self.bounds.origin.x, self.bounds.size.height - 30, self.bounds.size.width, 30));
    _textLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.300];
    _textLabel.font = [UIFont systemFontOfSize:14];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_textLabel];
}

//设置计时器
- (void)setupAnimationTimerWithDuration:(NSTimeInterval)animationDuration
{
    if (animationDuration > 0.0f) {//设置计时器
        if (!animationTimer) animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationDuration target:self selector:@selector(animationTimerDidFired:) userInfo:nil repeats:YES];

        //获取页数
        self.delegate ?//监听代理并回调
        [self setPagesCount:[self.delegate numberOfPagesInCarouselView:self]] :
        self.numberOfPagesBlock ?//监听块并回调
        [self setPagesCount:self.numberOfPagesBlock(self)] :
        //暂停计时器
        [animationTimer pauseTimer];
    }
}

//设置内容页
- (void)setupContentView
{
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setScrollViewDataSource];

    //设置一个计数器
    NSInteger counter = 0;

    //设置内容页（遍历每一页的内容）
    for (UIView *contentView in contentViews) {

        //打开用户交互
        contentView.userInteractionEnabled = YES;

        //添加点击事件
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [contentView addGestureRecognizer:recognizer]; recognizer = nil;

        //设置内容尺寸和位移
        CGRect frame = contentView.frame;
        frame.origin = CGPointMake(CGRectGetWidth(_scrollView.frame) * (counter++), 0);
        contentView.frame = frame;
        [_scrollView addSubview:contentView];
    }
    [_scrollView setContentOffset:CGPointMake(CGRectGetWidth(_scrollView.frame), 0)];
}

#pragma mark - Property Methods

//是否显示页控制器（白点）的setter方法
- (void)setPageControlShow:(BOOL)pageControlShow
{
    _pageControlShow = pageControlShow;
    if (!pageControlShow) [_pageControl removeFromSuperview], _pageControl = nil;
}

//是否显示文本的setter方法
- (void)setTextLabelShow:(BOOL)textLabelShow
{
    _textLabelShow = textLabelShow;
    if (!textLabelShow) [_textLabel removeFromSuperview], _textLabel = nil;
}

#pragma mark - Private Methods

//设置总页数
- (void)setPagesCount:(NSInteger)count
{
    pagesCount = count;
    if (pagesCount > 0) {
        [self setupContentView];
        //恢复计时器（指定时间间隔后恢复）
        [animationTimer resumeTimerAfterTimeInterval:_animationDuration];
    }

    //设置页控制器（白点）的总数
    _pageControl.numberOfPages = count;
}

//设置滚动视图的数据源
- (void)setScrollViewDataSource
{
    //获取上一页的页数
    NSInteger previousPage = [self getPage:currentPage - 1];

    //获取下一页的页数
    NSInteger nextPage = [self getPage:currentPage + 1];

    //设置内容页数组
    if (contentViews == nil) contentViews = [@[] mutableCopy]; [contentViews removeAllObjects];

    //添加内容页
    self.delegate ?//监听代理并回调
    ([contentViews addObject:[self.delegate carouselView:self contentViewAtIndex:previousPage]],
     [contentViews addObject:[self.delegate carouselView:self contentViewAtIndex:currentPage]],
     [contentViews addObject:[self.delegate carouselView:self contentViewAtIndex:nextPage]]) :
    //监听块并回调
    ([contentViews addObject:self.contentViewBlock(self, previousPage)],
     [contentViews addObject:self.contentViewBlock(self, currentPage)],
     [contentViews addObject:self.contentViewBlock(self, nextPage)]);

    //设置页控制器（白点）
    if ([self.delegate respondsToSelector:@selector(carouselView:pageControl:atIndex:)]) {//监听代理并回调
        [self.delegate carouselView:self pageControl:_pageControl atIndex:currentPage];
    } else if (self.pageControlBlock) {//监听块并回调
        self.pageControlBlock(self, _pageControl, currentPage);
    }

    //设置文本
    if ([self.delegate respondsToSelector:@selector(carouselView:textLabel:atIndex:)]) {//监听代理并回调
        [self.delegate carouselView:self textLabel:_textLabel atIndex:currentPage];
    } else if (self.textLabelBlock) {//监听块并回调
        self.textLabelBlock(self, _textLabel, currentPage);
    }
}

//获取下一页的页数
- (NSInteger)getPage:(NSInteger)page
{
    /*
     *p.s. 因为滚动视图的滚动数是从0开始，所以滚动数是总数-1
     */
    //如果传入的页数为-1，返回总页数-1（当前页为最后一页）
    if (page == -1) return pagesCount - 1;
    //如果传入的页数等于总页数，返回第0页（当前页为第一页）
    else if (page == pagesCount) return 0;
    //如果传入的页数不是第一页也不是最后一页，则当前页为此页
    else return page;
}

#pragma mark - Public Methods

//停止滚动
- (void)stop
{
    [animationTimer pauseTimer];
}

//恢复滚动
- (void)resume
{
    [animationTimer resumeTimer];
}

//刷新
- (void)refresh
{
    //暂停计时器
    [animationTimer pauseTimer];

    /*
     *p.s. 因为滚动视图的滚动数是从0开始，所以当前页为0，其实是第一页
     */
    //设置当前页为第一页
    currentPage = 0;

    //滚动视图
    if (_scrollView) [_scrollView removeFromSuperview], _scrollView = nil;
    [self setupScrollView];

    //页控制器（白点）
    if (_pageControl) pageControlCenter = _pageControl.center, [_pageControl removeFromSuperview], _pageControl = nil;
    if (_pageControlShow) [self setupPageControl];

    //文本
    if (_textLabel) textLabelFrame = _textLabel.frame, [_textLabel removeFromSuperview], _textLabel = nil;
    if (_textLabelShow) [self setupTextLabel];

    //计时器
    [self setupAnimationTimerWithDuration:_animationDuration];
}

#pragma mark -

//获取页数
- (void)numberOfPagesInCarouselViewUsingBlock:(NSInteger (^)(PFCarouselView *))block
{
    if (block) self.numberOfPagesBlock = block, block = nil;
    if (self.contentViewBlock) [self setPagesCount:self.numberOfPagesBlock(self)];
}

//获取视图
- (void)contentViewAtIndexUsingBlock:(UIView *(^)(PFCarouselView *, NSInteger))block
{
    if (block) self.contentViewBlock = block, block = nil;
    if (self.numberOfPagesBlock) [self setPagesCount:self.numberOfPagesBlock(self)];
}

//获取页控制器（白点）
- (void)pageControlAtIndexUsingBlock:(void (^)(PFCarouselView *, UIPageControl *, NSInteger))block
{
    if (block) {
        block(self, _pageControl, currentPage);
        self.pageControlBlock = block, block = nil;
    }
}

//获取文本
- (void)textLabelAtIndexUsingBlock:(void (^)(PFCarouselView *, UILabel *, NSInteger))block
{
    if (block) {
        block(self, _textLabel, currentPage);
        self.textLabelBlock = block, block = nil;
    }
}

//获取点击事件
- (void)didSelectViewAtIndexUsingBlock:(void (^)(PFCarouselView *, NSInteger))block
{
    if (block) self.tapBlock = block, block = nil;
}

#pragma mark - Events Management

//计时器开始
- (void)animationTimerDidFired:(NSTimer *)timer
{
    //设置位移的数值
    CGPoint offset = CGPointMake(_scrollView.contentOffset.x + CGRectGetWidth(_scrollView.frame), _scrollView.contentOffset.y);

    //设置位移
    [_scrollView setContentOffset:offset animated:YES];
}

//内容页被点击
- (void)tap
{
    if ([self.delegate respondsToSelector:@selector(carouselView:didSelectViewAtIndex:)]) {//监听代理并回调
        [self.delegate carouselView:self didSelectViewAtIndex:currentPage];
    } else if (self.tapBlock) {//监听块并回调
        self.tapBlock(self, currentPage);
    }
}

#pragma mark - UIScrollViewDelegate

//开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [animationTimer pauseTimer];
}

//结束拖拽并且开始减速
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //恢复计时器（指定时间间隔后恢复）
    [animationTimer resumeTimerAfterTimeInterval:_animationDuration];
}

//停止减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:YES];
}

//滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.x >= (2 * CGRectGetWidth(scrollView.frame))) {//翻到下一页
        currentPage = [self getPage:currentPage + 1];
        [self setupContentView];
    }
    if(scrollView.contentOffset.x <= 0) {//翻到上一页
        currentPage = [self getPage:currentPage - 1];
        [self setupContentView];
    }

    //设置页控制器（白点）为当前页
    _pageControl.currentPage = currentPage;
}

#pragma mark - Memory Management

- (void)dealloc
{
#if __has_feature(objc_arc)
    self.numberOfPagesBlock = nil;
    self.contentViewBlock   = nil;
    self.pageControlBlock   = nil;
    self.textLabelBlock     = nil;
    self.tapBlock           = nil;

    self.delegate           = nil;
#else
#endif
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end