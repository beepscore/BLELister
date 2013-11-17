//
//  BSDetailViewControllerTests.m
//  BLELister
//
//  Created by Steve Baker on 11/16/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BSDetailViewController.h"
#import "BSDetailViewController_Private.h"

@interface BSDetailViewControllerTests : XCTestCase

@end

@implementation BSDetailViewControllerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testViewDidLoadSetsLeDiscovery
{
    BSDetailViewController *vc = [[BSDetailViewController alloc] init];
    XCTAssertNil(vc.leDiscovery, @"expected leDiscovery nil");
    [vc viewDidLoad];
    XCTAssertNotNil(vc.leDiscovery, @"expected leDiscovery");
}

@end
