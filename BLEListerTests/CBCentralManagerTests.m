//  BLEListerTests
//
//  Created by Steve Baker on 11/07/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//
// This class tests Apple's CoreBluetooth framework class CBCentralManager.
// In general, it's not necessary to test Apple's code.
// The tests provide a way to check I'm using the class correctly.

#import <XCTest/XCTest.h>
#import "SHTestCaseAdditions.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BSBleConstants.h"

@interface CBCentralManagerTests : XCTestCase
@property (strong, nonatomic) CBCentralManager *centralManager;
@end

@implementation CBCentralManagerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark -
- (void)testState {
    self.centralManager = [[CBCentralManager alloc]
                           initWithDelegate:nil
                           queue:nil];
    
    // centralManager state varies.
    
    NSLog(@"centralManager state: %d", (int)self.centralManager.state);
    
    BOOL isValidManagerState = ( (CBCentralManagerStateUnknown == self.centralManager.state)
                                || (CBCentralManagerStateResetting == self.centralManager.state)
                                || (CBCentralManagerStateUnsupported == self.centralManager.state)
                                || (CBCentralManagerStateUnauthorized == self.centralManager.state)
                                || (CBCentralManagerStatePoweredOff == self.centralManager.state)
                                || (CBCentralManagerStatePoweredOn == self.centralManager.state)
                                );
    
    XCTAssertTrue(isValidManagerState, @"expected centralManager state valid");
}

@end
