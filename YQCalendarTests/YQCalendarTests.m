//
//  YQCalendarTests.m
//  YQCalendarTests
//
//  Created by 王叶庆 on 15/8/19.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <DateTools.h>
#import "YQCalendar.pch"
@interface YQCalendarTests : XCTestCase

@end

@implementation YQCalendarTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
    
}
- (void)testAfterMonth{
    NSDate *now = [NSDate date];
    
    DDLogInfo(@"moth number = %ld",[now dateByAddingMonths:1].month);
}
- (void)testAgoUtil{
    DDLogInfo(@"ago or util = %ld",[[[NSDate date] dateByAddingDays:-1] daysAgo]);
}
- (void)testWeekDay{//weekDayOrdinal是指本月的第几个星期几
    NSDate *date = [[NSDate date] dateByAddingDays:3];
    DDLogInfo(@"weekDay = %ld, ordinal = %ld",date.weekday,date.weekdayOrdinal);
}
- (void)testMothThan{
    NSDate *max = [NSDate dateWithYear:2000 month:1 day:31];
    NSDate *min = [NSDate dateWithYear:2000 month:1 day:1];
    NSLog(@"dis = %ld",[max monthsLaterThan:min]);
//    NSAssert([max monthsLaterThan:min]==1, @"不对啊");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
