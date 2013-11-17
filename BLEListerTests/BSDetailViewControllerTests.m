//
//  BSDetailViewControllerTests.m
//  BLELister
//
//  Created by Steve Baker on 11/16/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"
#import "BSDetailViewController.h"
#import "BSDetailViewController_Private.h"

@interface BSDetailViewControllerTests : XCTestCase

typedef void (^BSBLENotificationBlock)(id, NSNotification*);

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

- (void)testViewDidLoadSetsNotificationCenter
{
    BSDetailViewController *vc = [[BSDetailViewController alloc] init];
    XCTAssertNil(vc.notificationCenter, @"expected notificationCenter nil");
    [vc viewDidLoad];
    XCTAssertNotNil(vc.notificationCenter, @"expected notificationCenter");
    XCTAssertEqualObjects([NSNotificationCenter defaultCenter],
                          vc.notificationCenter,
                          @"expected viewDidLoad sets notificationCenter to defaultCenter");
}

/**
  Use block parameter.
  Blocks are flexible and powerful, method will be easy to modify if needed.
  Alternatively could pass a selector.
  However selector has several disadvantages:
  - It's cumbersome for the caller to pass the selector argument
  - compiler warns selector may create a leak
 */
- (void)checkDiscoveryNotificationCallsUpdateUIOnMainQueue:(BSBLENotificationBlock)aNotificationBlock
{

    BSDetailViewController *vc = [[BSDetailViewController alloc] init];
    // Use mock to avoid warning
    // CoreBluetooth[WARNING] <CBPeripheral: 0x176f9860
    // identifier = (null), Name = "(null)", state = disconnected> is not a valid peripheral
    id mockPeripheral = [OCMockObject niceMockForClass:[CBPeripheral class]];
    [[[mockPeripheral stub] andReturn:@"123"] identifier];
    [[[mockPeripheral stub] andReturn:@"joe"] name];
    // To check state in debugger, must cast type
    // $ p (CBPeripheralState)[mockPeripheral state]
    // (CBPeripheralState) $1 = CBPeripheralStateConnected
    [[[mockPeripheral stub] andReturnValue:OCMOCK_VALUE(CBPeripheralStateConnected)] state];
    vc.detailItem = mockPeripheral;

    // discoveryDidConnectPeripheralWithNotification: checks
    // notification userInfo peripheral equals self.detailItem
    NSDictionary *userInfo = @{@"peripheral" : mockPeripheral};
    NSNotification *notification = [NSNotification notificationWithName:@"boo"
                                                                 object:self
                                                               userInfo:userInfo];

    id mockDetailViewController = [OCMockObject partialMockForObject:vc];
    [[[mockDetailViewController stub] andReturn:vc.detailItem] detailItem];
    [[mockDetailViewController expect] updateUIOnMainQueue];

    // call block, using local values for arguments
    aNotificationBlock(mockDetailViewController, notification);

    // Verify all stubbed or expected methods were called.
    [mockDetailViewController verify];
}

- (void)testDiscoveryDidConnectPeripheralWithNotificationCallsUpdateUIOnMainQueue
{
    BSBLENotificationBlock notificationBlock = ^(id aMock, NSNotification *aNotification) {
        [aMock discoveryDidConnectPeripheralWithNotification:aNotification];
    };
    
    [self checkDiscoveryNotificationCallsUpdateUIOnMainQueue:notificationBlock];
}

- (void)testDiscoveryDidDisconnectPeripheralWithNotificationCallsUpdateUIOnMainQueue
{
    BSBLENotificationBlock notificationBlock = ^(id aMock, NSNotification *aNotification) {
        [aMock discoveryDidDisconnectPeripheralWithNotification:aNotification];
    };
    
    [self checkDiscoveryNotificationCallsUpdateUIOnMainQueue:notificationBlock];
}

@end
