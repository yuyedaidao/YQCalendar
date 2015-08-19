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

- (void)testMothThan{
    NSDate *max = [NSDate dateWithYear:2015 month:12 day:29];
    NSDate *min = [NSDate dateWithYear:2015 month:11 day:30];
    NSLog(@"dis = %ld",[max monthsLaterThan:min]);
    NSAssert([max monthsLaterThan:min]==1, @"不对啊");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
