//
//  RootVC.m
//  Demo
//
//  Created by PFei_He on 14-11-28.
//  Copyright (c) 2014年 PF-Lib. All rights reserved.
//

#import "RootVC.h"

@interface RootVC ()

@end

@implementation RootVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //视图数组
    viewsArray = [@[] mutableCopy];

    //视图背景颜色的数组
    NSArray *colorArray = @[[UIColor cyanColor], [UIColor blueColor], [UIColor greenColor], [UIColor yellowColor], [UIColor purpleColor]];
    textsArray = @[@"0", @"1", @"2", @"3", @"4"];

    //遍历视图
    for (int i = 0; i < colorArray.count; ++i) {
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
        tempLabel.backgroundColor = [(UIColor *)[colorArray objectAtIndex:i] colorWithAlphaComponent:0.5];
        [viewsArray addObject:tempLabel];
    }

    //创建一个轮播图
    PFCarouselView *carouselView = [[PFCarouselView alloc] initWithFrame:CGRectMake(0, 100, 320, 200)];
    
    //设置时间间隔
    carouselView.duration = 2.0f;
    
    //设置代理
    carouselView.delegate = self;
    
    //轮播图的背景
    carouselView.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.1];
/*
    //设置页数
    [carouselView numberOfPagesUsingBlock:^NSInteger{
        return viewsArray.count;
    }];
    
    //设置视图
    [carouselView setupContentViewUsingBlock:^UIView *(NSInteger index) {
        return viewsArray[index];
    }];

    //设置文本
    [carouselView resetTextLabelUsingBlock:^(UILabel *textLabel, NSInteger index) {
        textLabel.text = textsArray[index];
    }];

    //设置点击事件
    [carouselView didSelectViewUsingBlock:^(NSInteger index) {
        NSLog(@"点击了第%d个", index);
    }];
*/
    //开始滚动
    [carouselView resume];
    
    [self.view addSubview:carouselView];
}

#pragma mark - PFCarouselViewDelegate

//设置页数
- (NSInteger)numberOfPagesInCarouselView:(PFCarouselView *)carouselView
{
    return viewsArray.count;
}

//设置视图
- (UIView *)carouselView:(PFCarouselView *)carouselView setupContentViewAtIndex:(NSInteger)index
{
    return viewsArray[index];
}

//设置文本
- (void)carouselView:(PFCarouselView *)carouselView resetTextLabel:(UILabel *)textLabel atIndex:(NSInteger)index
{
    textLabel.text = textsArray[index];
}

//设置点击事件
- (void)carouselView:(PFCarouselView *)carouselView didSelectViewAtIndex:(NSInteger)index
{
    NSLog(@"点击了第%d个", index);
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
