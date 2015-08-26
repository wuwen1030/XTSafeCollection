//
//  XTSafeCollectionTests.m
//  XTSafeCollectionTests
//
//  Created by Ben on 15/8/25.
//  Copyright (c) 2015年 X-Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface XTSafeCollectionTests : XCTestCase

@end

@implementation XTSafeCollectionTests

- (void)testArrayInit
{
    NSNumber *aNil = nil;
    NSArray *array1 = @[@1, @2, aNil, @4];
    NSArray *array2 = @[@1, @2, @4];
    XCTAssertEqualObjects(array1, array2);
}

- (void)testArrayObjectAtIndex
{
    NSArray *array = @[@1,@2];
    XCTAssert(array[0]);
    XCTAssertNil(array[array.count]);
}

- (void)testMutableArrayObjectAtIndex
{
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@1, @2,nil];
    XCTAssert(array[0]);
    XCTAssertNil(array[array.count]);
}

- (void)testMutableArrayAddObject
{
    NSMutableArray *array1 = [NSMutableArray arrayWithObjects:@1, @2,nil];
    [array1 addObject:nil];
    NSMutableArray *array2 = [NSMutableArray arrayWithArray:array1];
    XCTAssertEqualObjects(array1, array2);
}

@end
