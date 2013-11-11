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

- (void)testState {
    // Init with queue nil (uses default main queue), test failed.
    // self.centralManager = [[CBCentralManager alloc] initWithDelegate:nil queue:nil];
    // Init with queue non-nil, test passes.
    // http://stackoverflow.com/questions/18970247/cbcentralmanager-changes-for-ios-7
    dispatch_queue_t centralQueue = dispatch_queue_create("com.beepscore.central_manager", DISPATCH_QUEUE_SERIAL);
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:nil queue:centralQueue];
    
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

    NSLog(@"peripheralsWithIdentifiers %@", peripheralsWithIdentifiers);
    XCTAssertNotNil(peripheralsWithIdentifiers, @"");
    XCTAssertTrue((1 <= [peripheralsWithIdentifiers count]),
                  @"expected peripheralsWithIdentifiers has 1 or more objects");

    CBPeripheral *peripheral = [peripheralsWithIdentifiers firstObject];

    XCTAssertEqualObjects(expectedIdentifier,
                          peripheral.identifier,
                          @"expected peripheral identifier");
    XCTAssertNil(peripheral.name, @"expected peripheral name nil");
}

@end
