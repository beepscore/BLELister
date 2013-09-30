//
//  BSLeDiscoveryTests.m
//  BLEListerTests
//
//  Created by Steve Baker on 9/26/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SHTestCaseAdditions.h"
#import "BSLeDiscovery.h"
#import "BSLeDiscovery_Private.h"

@interface BSLeDiscoveryTests : XCTestCase
@property (strong, nonatomic) BSLeDiscovery *bsLeDiscovery;
@end

@implementation BSLeDiscoveryTests

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

#pragma mark - test sharedInstance
- (void)testSharedInstance {
    self.bsLeDiscovery = [BSLeDiscovery sharedInstance];
    // call sharedInstance again to check it returns the same instance
    // XCTAssertEqual is the identical object
    // XCTAssertEqualObjects tests objectA isEqual:objectB
    XCTAssertEqual([BSLeDiscovery  sharedInstance],
                   self.bsLeDiscovery,
                   @"expected sharedInstance returns same instance");
}

- (void)testSharedInstanceCentralManager {
    self.bsLeDiscovery = [BSLeDiscovery sharedInstance];
    // Could reduce scope of this test by testing sharedInstance calls
    // designated initializer.
    XCTAssertNotNil(self.bsLeDiscovery.centralManager,
                   @"expected sharedInstance sets centralManager");
}

- (void)testSharedInstanceCentralManagerState {
    self.bsLeDiscovery = [BSLeDiscovery sharedInstance];
    // centralManager state varies.
    // Delay did not cause centralManager state to stabilize
    //[self SH_waitForTimeInterval:15];

    NSLog(@"centralManager state: %d", (int)self.bsLeDiscovery.centralManager.state);

    BOOL isValidManagerState = ( (CBCentralManagerStateUnknown == self.bsLeDiscovery.centralManager.state)
                                || (CBCentralManagerStateResetting == self.bsLeDiscovery.centralManager.state)
                                || (CBCentralManagerStateUnsupported == self.bsLeDiscovery.centralManager.state)
                                || (CBCentralManagerStateUnauthorized == self.bsLeDiscovery.centralManager.state)
                                || (CBCentralManagerStatePoweredOff == self.bsLeDiscovery.centralManager.state)
                                || (CBCentralManagerStatePoweredOn == self.bsLeDiscovery.centralManager.state)
                                );
    XCTAssertTrue(isValidManagerState, @"expected centralManager state valid");
}

- (void)testSharedInstanceCentralManagerDelegate {
    self.bsLeDiscovery = [BSLeDiscovery sharedInstance];
    // Could reduce scope of this test by testing sharedInstance calls
    // designated initializer.
    XCTAssertEqualObjects(self.bsLeDiscovery,
                          self.bsLeDiscovery.centralManager.delegate,
                   @"expected sharedInstance sets centralManager delegate to self");
}

// testSharedInstanceFoundPeriperals requires an Arduino with RedBearLab BLE shield
// within range of the iOS device.
// Currently this test passes
- (void)testSharedInstanceFoundPeriperals {
    self.bsLeDiscovery = [BSLeDiscovery sharedInstance];

    [self.bsLeDiscovery.centralManager scanForPeripheralsWithServices:nil options:nil];
    // Need to add some delay to enable test to pass.
    [self SH_waitForTimeInterval:10];

    XCTAssertNotNil(self.bsLeDiscovery.foundPeripherals,
                    @"expected sharedInstance sets foundPeripherals");
    XCTAssertTrue((0 <= [self.bsLeDiscovery.foundPeripherals count]),
                  @"expected foundPeripherals has 0 or more objects");

    NSLog(@"foundPeripherals: %@", self.bsLeDiscovery.foundPeripherals);

    CBPeripheral *peripheral = [self.bsLeDiscovery.foundPeripherals firstObject];

    // RedBearLab BLE shield for Arduino service UUID
    NSString *redBearLabBLEShieldServiceUUIDString = @"DDAB0207-5E10-2902-5B03-CA3F0F466B40";
    XCTAssertEqualObjects(redBearLabBLEShieldServiceUUIDString,
                          [peripheral.identifier UUIDString],
                          @"expected first found peripheral UUIDString");
    XCTAssertEqualObjects(@"BLE Shield",
                          peripheral.name,
                             @"expected first found peripheral name");
}

- (void)testSharedInstanceConnectedServices {
    self.bsLeDiscovery = [BSLeDiscovery sharedInstance];
    // Could reduce scope of this test by testing sharedInstance calls
    // designated initializer.
    XCTAssertNotNil(self.bsLeDiscovery.connectedServices,
                    @"expected sharedInstance sets connectedServices");
    XCTAssertEqualObjects(@[],
                          self.bsLeDiscovery.connectedServices,
                          @"expected sharedInstance connectedServices is empty array");
}

# pragma mark - test designated initializer
- (void)testDesignatedInitializerWithParamsNil {
    self.bsLeDiscovery = [[BSLeDiscovery alloc]
                          initWithCentralManager:nil
                          foundPeripherals:nil
                          connectedServices:nil];
    XCTAssertNil(self.bsLeDiscovery.centralManager,
                 @"expected centralManager nil");
    XCTAssertNil(self.bsLeDiscovery.foundPeripherals,
                @"expected foundPeripherals nil");
    XCTAssertNil(self.bsLeDiscovery.connectedServices,
                @"expected connectedServices nil");
}

# pragma mark - test asynchronous
- (void)testSH_waitForTimeInterval {
    __block BOOL assertion = NO;

    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        assertion = YES;
    });

    [self SH_waitForTimeInterval:delayInSeconds];
    XCTAssertTrue(assertion, @"expected assertion true");
}

// FIXME: currently this test fails by timing out
- (void)testFoundPeripherals {

    // using __block allows block to change bsLeDiscovery, set property foundPeripherals??
    __block BSLeDiscovery *bsLeDiscovery = [BSLeDiscovery sharedInstance];

    XCTAssertEqualObjects(@[],
                          bsLeDiscovery.foundPeripherals,
                          @"expected foundPeripherals is empty array");

    // http://stackoverflow.com/questions/10178293/how-to-get-list-of-available-bluetooth-devices?rq=1
    // https://developer.bluetooth.org/gatt/services/Pages/ServicesHome.aspx
    // NSString *uuidString = @"180D";
    // RedBearLab BLE shield for Arduino service UUID
    // NSString *redBearLabBLEShieldServiceUUIDString = @"DDAB0207-5E10-2902-5B03-CA3F0F466B40";
    //[bsLeDiscovery startScanningForUUIDString:redBearLabBLEShieldServiceUUIDString];

    [bsLeDiscovery startScanningForUUIDString:nil];

    SHTestCaseBlock testBlock = ^(BOOL *didFinish) {

        NSLog(@"********************************");
        NSLog(@"foundPeripherals: %@", bsLeDiscovery.foundPeripherals);
        if ( 1 <= [bsLeDiscovery.foundPeripherals count]) {

            NSLog(@"********************************");
            NSLog(@"foundPeripherals: %@", bsLeDiscovery.foundPeripherals);
            CBPeripheral *peripheral = [bsLeDiscovery.foundPeripherals firstObject];

            // RedBearLab BLE shield for Arduino service UUID
            NSString *redBearLabBLEShieldServiceUUIDString = @"DDAB0207-5E10-2902-5B03-CA3F0F466B40";
            XCTAssertEqualObjects(redBearLabBLEShieldServiceUUIDString,
                                  [peripheral.identifier UUIDString],
                                  @"expected first found peripheral UUIDString");
            XCTAssertEqualObjects(@"BLE Shield",
                                  peripheral.name,
                                  @"expected first found peripheral name");
            *didFinish = YES;
        }
    };

    [self SH_performAsyncTestsWithinBlock:testBlock withTimeout:20.0];
}

@end
