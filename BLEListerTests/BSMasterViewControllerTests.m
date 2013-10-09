//
//  BSMasterViewControllerTests.m
//  BLELister
//
//  Created by Steve Baker on 10/9/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BSMasterViewController.h"

@interface BSMasterViewControllerTests : XCTestCase

@end

@implementation BSMasterViewControllerTests

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
    BSMasterViewController *vc = [[BSMasterViewController alloc] init];
    [vc viewDidLoad];
    XCTAssertNotNil(vc.leDiscovery, @"expected leDiscovery");

    // FIXME: this fails, 2 different objects.
    // sharedInstance dispatchOnce is getting called twice!
    //XCTAssertEqualObjects([BSLeDiscovery sharedInstance], vc.leDiscovery, @"expected leDiscovery");
}

@end
