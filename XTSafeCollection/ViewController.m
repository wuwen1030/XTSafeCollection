//
//  ViewController.m
//  XTSafeCollection
//
//  Created by Ben on 15/8/25.
//  Copyright (c) 2015年 X-Team. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    NSArray *array = @[@"a", @"b"];
    NSMutableArray *mutableArray = [@[@"aa", @"bb"] mutableCopy];
    
    // Object at index
    NSLog(@"%@", array[10]);
    NSLog(@"%@", mutableArray[100]);
    
    // add object
    [mutableArray addObject:nil];
    
    // Insert object
    [mutableArray insertObject:nil atIndex:0];
    [mutableArray insertObject:@"cc" atIndex:10];
    
    // Replace object
    [mutableArray replaceObjectAtIndex:0 withObject:nil];
    [mutableArray replaceObjectAtIndex:10 withObject:@"cc"];
    
    // Dictionary
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    mutableDictionary[nil] = @"1";
    mutableDictionary[@"1"] = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
