//
//  CalendarViewController.m
//  YQCalendar
//
//  Created by Wang on 15/8/24.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import "CalendarViewController.h"
#import "YQCalendar.h"
@interface CalendarViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    DDLogDebug(@"calendar view = %@",NSStringFromCGRect(self.view.frame));
//    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.frame = self.view.bounds;
    YQCalendar *calendar = [[YQCalendar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 50*6)];
    [self.tableView addCalendar:calendar];
    
    YQCalendarHeader *header = [[YQCalendarHeader alloc] initWithFrame:CGRectMake(0,self.automaticallyAdjustsScrollViewInsets? NavHeight(self):0, calendar.bounds.size.width, [YQCalendarAppearence share].headerHeight)];
    header.backgroundColor = [UIColor orangeColor];
//    self.tableView.tableHeaderView = header;
    [self.view addSubview:header];
    YQCalendar *weekCalendar = [[YQCalendar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(header.frame)+50*5, self.tableView.bounds.size.width, 50) appearence:nil mode:YQCalendarModeWeek];
    [self.view addSubview:weekCalendar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 100;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
