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
#import "BSJSONParser.h"
#import "BSLeDiscovery.h"
#import "BSLeDiscovery_Private.h"

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
// This test fails
// I think Xcode may be running app before starting tests.
// Even if I choose to run only this test,
// Xcode creates a [BSLeDiscovery sharedInstance] with a centralManager.
// Test creates a central manager, but it doesn't become powered on.
// Possible causes:
// Central manager may need a delegate.
// Could be because only one centralManager can be poweredOn,
// Could be because test runs in background and iOS won't let it power on.
// If centralManager used by tests isn't powered on, then scans won't work.
// If test references [BSLeDiscovery sharedInstance] it gets a second one.
// Possible fixes:
// Might be able to change unit test scheme to not build app first.
// Might be able to make initial [BSLeDiscovery sharedInstance] available to test.

- (void)testState {
    //self.centralManager = [[BSLeDiscovery sharedInstance] centralManager];

    self.centralManager = [[CBCentralManager alloc] initWithDelegate:nil queue:nil];

    NSLog(@"%@ state: %d", self.centralManager,
          (int)self.centralManager.state);

    // This didn't cause centralManager to power on.
    //[self.centralManager scanForPeripheralsWithServices:nil options:nil];

    // This didn't cause centralManager to power on.
    //NSUUID *uuidIdentifier =[[NSUUID alloc] initWithUUIDString:@"DDAB0207-5E10-2902-5B03-CA3F0F466B40"];
//    NSArray *peripheralsWithIdentifiers = [self.centralManager
//                                          retrievePeripheralsWithIdentifiers:@[uuidIdentifier]];

    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:15];

    while ( (CBCentralManagerStatePoweredOn != self.centralManager.state)
           && [[timeoutDate laterDate:[NSDate date]] isEqualToDate:timeoutDate]) {
        NSLog(@"%@ state: %d", self.centralManager,
              (int)self.centralManager.state);
        sleep(1);
    }
    XCTAssertEqual(CBCentralManagerStatePoweredOn, self.centralManager.state,
                     @"expected centralManager state on");
}


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

    NSLog(@"peripheralsWithIdentifiers %@", peripheralsWithIdentifiers);
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

@end
