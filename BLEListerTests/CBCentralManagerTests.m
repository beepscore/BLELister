//  BLEListerTests
//
//  Created by Steve Baker on 11/07/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//
// This class tests Apple's CoreBluetooth framework class CBCentralManager.
// In general, it's not necessary to test Apple's code.
// The tests provide a way to check I'm using the class correctly.
// Also test category CBCentralManager_BSSafe

#import <XCTest/XCTest.h>
#import "SHTestCaseAdditions.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BSBleConstants.h"
#import "BSJSONParser.h"
#import "OCMock/OCMock.h"
#import "CBCentralManager_BSSafe.h"

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

// This test is synchronous, blocks main thread
- (void)testState {
    // Init with queue nil (uses default main queue), test failed.
    // centralManager = [[CBCentralManager alloc] initWithDelegate:nil queue:nil];
    // Init with queue non-nil, test passes.
    // http://stackoverflow.com/questions/18970247/cbcentralmanager-changes-for-ios-7
    dispatch_queue_t centralQueue = dispatch_queue_create("com.beepscore.central_manager", DISPATCH_QUEUE_SERIAL);
    CBCentralManager *centralManager = [[CBCentralManager alloc]
                                        initWithDelegate:nil queue:centralQueue];
    
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:10];
    
    while ( (CBCentralManagerStatePoweredOn != centralManager.state)
           && [[timeoutDate laterDate:[NSDate date]] isEqualToDate:timeoutDate]) {
        DDLogVerbose(@"%@ CBCentralManagerState: %ld", centralManager, centralManager.state);
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }
    XCTAssertEqual(CBCentralManagerStatePoweredOn, centralManager.state,
                   @"expected centralManager state on");
}

// TODO: The test fails when run with other tests, passes when run by itself.
// This test is asynchronous. It tests the same thing as testState.
/*
- (void)testStateAsync {
    // Init with queue nil (uses default main queue), test failed.
    // CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:nil queue:nil];
    // Init with queue non-nil, test passes.
    // http://stackoverflow.com/questions/18970247/cbcentralmanager-changes-for-ios-7
    dispatch_queue_t centralQueue = dispatch_queue_create("com.beepscore.central_manager", DISPATCH_QUEUE_SERIAL);
    CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:nil queue:centralQueue];

    SHTestCaseBlock testBlock = ^(BOOL *didFinish) {

        DDLogVerbose(@"In testBlock.");
        DDLogVerbose(@"centralManager %@ state %d", centralManager, centralManager.state);

        if (CBCentralManagerStatePoweredOn == centralManager.state) {

            XCTAssertEqual(CBCentralManagerStatePoweredOn, centralManager.state,
                    @"expected centralManager state on");
            // dereference the pointer to set the BOOL value
            *didFinish = YES;
        }
    };

    // SH_performAsyncTestsWithinBlock calls testBlock
    // and supplies its argument, a pointer to BOOL didFinish.
    // SH_performAsyncTestsWithinBlock keeps calling the block
    // until the block sets didFinish YES or the test times out.
    [self SH_performAsyncTestsWithinBlock:testBlock withTimeout:10.0];
}
 */

# pragma mark - test retrievePeripheral
- (void)retrievePeripheral:(NSString *)peripheralKey {

    // CBCentralManager wants a delegate that implements centralManagerDidUpdateState:
    // this test passes without a delegate.
    self.centralManager = [[CBCentralManager alloc]
                           initWithDelegate:nil
                           queue:nil];

    NSDictionary *bleDevices = [BSJSONParser dictFromJSONFile:@"bleDevices"];
    NSString *expectedIdentifierString = bleDevices[peripheralKey][@"identifier"];
    NSUUID *expectedIdentifier = [[NSUUID alloc] initWithUUIDString:expectedIdentifierString];
    NSString *expectedName = bleDevices[peripheralKey][@"name"];

    // NOTE: retrievePeripheralsWithIdentifiers: argument is array of NSUUID not CBUUID
    NSArray *peripheralsWithIdentifiers = [self.centralManager
                                           retrievePeripheralsWithIdentifiers:@[expectedIdentifier]];

    DDLogVerbose(@"peripheralsWithIdentifiers %@", peripheralsWithIdentifiers);
    XCTAssertNotNil(peripheralsWithIdentifiers, @"");
    XCTAssertTrue((1 <= [peripheralsWithIdentifiers count]),
                  @"expected peripheralsWithIdentifiers has 1 or more objects");

    CBPeripheral *peripheral = [peripheralsWithIdentifiers firstObject];

    XCTAssertEqualObjects(expectedIdentifier,
                          peripheral.identifier,
                          @"expected peripheral identifier");
    XCTAssertEqualObjects(expectedName,
                          peripheral.name,
                          @"expected peripheral name");
}

// This test passes even when BLE shield is off, and the app doesn't show the device in the table view.
// It must be getting stored info.
// testRetrievePeripheralBLEShield requires an Arduino with RedBearLab BLE shield
// within range of the iOS device.
// It assumes BLE shield with be the first device found.
- (void)testRetrievePeripheralBLEShield {
    [self retrievePeripheral:@"redbearshield"];
}

// testRetrievePeripheralTISensorTag requires a TI SensorTag within range of the iOS device.
// It assumes SensorTag will be the first device found.
// Before running test, press SensorTag side button to activate it.
- (void)testRetrievePeripheralTISensorTag {
    [self retrievePeripheral:@"sensortag"];
}

// This test passes even when Raspberry Pi is off, and the app doesn't show the device in the table view.
// I think it is getting stored info, or else the device is not the Raspberry Pi.
// testRetrievePeripheralRaspberryPi requires a Raspberry Pi with a BLE adapter
// configured as an iBeacon within range of the iOS device.
// It assumes Raspberry Pi will be the first device found.
- (void)testRetrievePeripheralRaspberryPi {
    // CBCentralManager wants a delegate that implements centralManagerDidUpdateState:
    // this test passes without a delegate.
    self.centralManager = [[CBCentralManager alloc]
                           initWithDelegate:nil
                           queue:nil];

    NSDictionary *bleDevices = [BSJSONParser dictFromJSONFile:@"bleDevices"];
    NSString *peripheralKey = @"raspberry_pi";
    NSString *expectedIdentifierString = bleDevices[peripheralKey][@"identifier"];
    NSUUID *expectedIdentifier = [[NSUUID alloc] initWithUUIDString:expectedIdentifierString];

    // NOTE: retrievePeripheralsWithIdentifiers: argument is array of NSUUID not CBUUID
    NSArray *peripheralsWithIdentifiers = [self.centralManager
                                           retrievePeripheralsWithIdentifiers:@[expectedIdentifier]];

    DDLogVerbose(@"peripheralsWithIdentifiers %@", peripheralsWithIdentifiers);
    XCTAssertNotNil(peripheralsWithIdentifiers, @"");
    XCTAssertTrue((1 <= [peripheralsWithIdentifiers count]),
                  @"expected peripheralsWithIdentifiers has 1 or more objects");

    CBPeripheral *peripheral = [peripheralsWithIdentifiers firstObject];

    XCTAssertEqualObjects(expectedIdentifier,
                          peripheral.identifier,
                          @"expected peripheral identifier");
    XCTAssertNil(peripheral.name, @"expected peripheral name nil");
}

# pragma mark - test safeScan
- (void)testSafeScanForPeripheralsWithServicesOptionsCentralManagerOff {

    CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:nil queue:nil];
    id mockCentralManager = [OCMockObject partialMockForObject:centralManager];
    // override readonly property state
    [[[mockCentralManager stub] andReturnValue:OCMOCK_VALUE(CBCentralManagerStatePoweredOff)] state];
    XCTAssertEqual(CBCentralManagerStatePoweredOff,
                   [mockCentralManager state], @"expect test set up mock powered off");

    // http://ocmock.org/features/
    [[mockCentralManager reject] scanForPeripheralsWithServices:OCMOCK_ANY
                                                            options:OCMOCK_ANY];
    [mockCentralManager safeScanForPeripheralsWithServices:OCMOCK_ANY
                                               options:OCMOCK_ANY];
    [mockCentralManager verify];
}

- (void)testSafeScanForPeripheralsWithServicesOptionsCentralManagerOn {

    CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:nil queue:nil];
    id mockCentralManager = [OCMockObject partialMockForObject:centralManager];
    // override readonly property state
    [[[mockCentralManager stub] andReturnValue:OCMOCK_VALUE(CBCentralManagerStatePoweredOn)] state];
    XCTAssertEqual(CBCentralManagerStatePoweredOn,
                   [mockCentralManager state], @"expect test set up mock powered on");

    [[mockCentralManager expect] scanForPeripheralsWithServices:OCMOCK_ANY
                                                            options:OCMOCK_ANY];
    [mockCentralManager safeScanForPeripheralsWithServices:OCMOCK_ANY
                                               options:OCMOCK_ANY];
    [mockCentralManager verify];
}

@end
