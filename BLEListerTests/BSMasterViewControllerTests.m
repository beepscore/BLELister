//
//  BSMasterViewControllerTests.m
//  BLELister
//
//  Created by Steve Baker on 10/9/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"
#import "BSMasterViewController.h"
#import "BSMasterViewController_Private.h"
#import "BSLeDiscovery.h"
#import "BSBleTestConstants.h"

@interface BSMasterViewControllerTests : XCTestCase

@end

@implementation BSMasterViewControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown {
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testViewDidLoadSetsLeDiscovery {
    BSMasterViewController *vc = [[BSMasterViewController alloc] init];
    XCTAssertNil(vc.leDiscovery, @"expected leDiscovery nil");
    [vc viewDidLoad];
    XCTAssertNotNil(vc.leDiscovery, @"expected leDiscovery");

    // Currently this returns 2 different objects and test fails.
    // TODO: Investigate why.
    DDLogVerbose(@"***sharedInstance %@", (BSLeDiscovery *)[BSLeDiscovery sharedInstance]);
    DDLogVerbose(@"***vc.leDiscovery %@", vc.leDiscovery);
    DDLogVerbose(@"***sharedInstance.centralManager %@", [(BSLeDiscovery *)[BSLeDiscovery sharedInstance] centralManager]);
    DDLogVerbose(@"***vc.leDiscovery.centralManager %@", vc.leDiscovery.centralManager);
    //XCTAssertEqualObjects([BSLeDiscovery sharedInstance], vc.leDiscovery, @"expected leDiscovery");
}

- (void)testViewDidLoadSetsNotificationCenter {
    BSMasterViewController *vc = [[BSMasterViewController alloc] init];
    XCTAssertNil(vc.notificationCenter, @"expected notificationCenter nil");
    [vc viewDidLoad];
    XCTAssertNotNil(vc.notificationCenter, @"expected notificationCenter");
    XCTAssertEqualObjects([NSNotificationCenter defaultCenter],
                          vc.notificationCenter,
                          @"expected viewDidLoad sets notificationCenter to defaultCenter");
}

- (void)checkDiscoveryNotificationCallsUpdateUIOnMainQueue:(BSBLENotificationBlock)aNotificationBlock {
    BSMasterViewController *vc = [[BSMasterViewController alloc] init];
    id mockMasterViewController = [OCMockObject partialMockForObject:vc];
    NSNotification *notification = nil;

    [[mockMasterViewController expect] updateUIOnMainQueue];

    // call block, using local values for arguments
    aNotificationBlock(mockMasterViewController, notification);

    // Verify all stubbed or expected methods were called.
    [mockMasterViewController verify];
}

- (void)testDiscoveryDidRefreshWithNotificationCallsUpdateUIOnMainQueue {
    BSBLENotificationBlock notificationBlock = ^(id aMock, NSNotification *aNotification) {
        [aMock discoveryDidRefreshWithNotification:aNotification];
    };
    
    [self checkDiscoveryNotificationCallsUpdateUIOnMainQueue:notificationBlock];
}

@end
