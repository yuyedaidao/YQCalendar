//
//  ViewController.m
//  YQCalendar
//
//  Created by 王叶庆 on 15/8/19.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import "ViewController.h"
#import "YQCalendar.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet YQCalendar *calendar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    YQCalendar *calendar = [[YQCalendar alloc] initWithFrame:CGRectMake(0, 0, 50*7, 50*7)];
    calendar.center = self.view.center;
    calendar.backgroundColor = [UIColor orangeColor];
    calendar.appearence.headerWeekTextColor = [UIColor greenColor];
    [self.view addSubview:calendar];
    
  
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [calendar testItemsLocation];
//    });
}
- (IBAction)change:(id)sender {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
