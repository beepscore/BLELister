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
#import "BSJSONParser.h"
#import "OCMock/OCMock.h"
#import "BSBleConstants.h"
#import "BSStubCBCentralManager.h"

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
    XCTAssertEqual([BSLeDiscovery sharedInstance],
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

- (void)findAndTestPeripheral:(NSString *)peripheralKey {
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

    NSDictionary *bleDevices = [BSJSONParser dictFromJSONFile:@"bleDevices"];
    NSString *expectedIdentifier = bleDevices[peripheralKey][@"identifier"];
    NSString *expectedName = bleDevices[peripheralKey][@"name"];

    XCTAssertEqualObjects(expectedIdentifier,
                          [peripheral.identifier UUIDString],
                          @"expected first found peripheral UUIDString");
    XCTAssertEqualObjects(expectedName,
                          peripheral.name,
                          @"expected first found peripheral name");
}

// testFoundPeripheralBLEShield requires an Arduino with RedBearLab BLE shield
// within range of the iOS device.
// It assumes BLE shield with be the first device found.
- (void)testFoundPeripheralBLEShield {
    [self findAndTestPeripheral:@"redbearshield"];
}

// testFoundPeripheralTISensorTag requires a TI SensorTag within range of the iOS device.
// It assumes SensorTag with be the first device found.
// Before running test, press SensorTag side button to activate it.
- (void)testFoundPeripheralTISensorTag {
    [self findAndTestPeripheral:@"sensortag"];
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

- (void)testSharedInstanceNotificationCenter {
    self.bsLeDiscovery = [BSLeDiscovery sharedInstance];
    // Could reduce scope of this test by testing sharedInstance calls
    // designated initializer.
    XCTAssertNotNil(self.bsLeDiscovery.notificationCenter,
                    @"expected sharedInstance sets notificationCenter");
    XCTAssertEqualObjects([NSNotificationCenter defaultCenter],
                          self.bsLeDiscovery.notificationCenter,
                          @"expected sharedInstance uses default notificationCenter");
}

# pragma mark - test designated initializer
- (void)testDesignatedInitializerSetsProperties {
    CBCentralManager *fakeCentralManager = [[CBCentralManager alloc] init];
    NSMutableArray *fakeFoundPeripherals = [NSMutableArray arrayWithArray:@[@"wolf", @"dog", @"dingo"]];
    NSMutableArray *fakeConnectedServices = [NSMutableArray arrayWithArray:@[@"lion", @"cat", @"lynx"]];
    NSNotificationCenter *fakeNotificationCenter = [[NSNotificationCenter alloc] init];

    self.bsLeDiscovery = [[BSLeDiscovery alloc]
                          initWithCentralManager:fakeCentralManager
                          foundPeripherals:fakeFoundPeripherals
                          connectedServices:fakeConnectedServices
                          notificationCenter:fakeNotificationCenter];

    XCTAssertEqualObjects(fakeCentralManager, self.bsLeDiscovery.centralManager, @"");
    XCTAssertEqualObjects(fakeFoundPeripherals, self.bsLeDiscovery.foundPeripherals, @"");
    XCTAssertEqualObjects(fakeConnectedServices, self.bsLeDiscovery.connectedServices, @"");
    XCTAssertEqualObjects(fakeNotificationCenter, self.bsLeDiscovery.notificationCenter, @"");
}

- (void)testDesignatedInitializerWithParamsNil {
    self.bsLeDiscovery = [[BSLeDiscovery alloc]
                          initWithCentralManager:nil
                          foundPeripherals:nil
                          connectedServices:nil
                          notificationCenter:nil];

    XCTAssertNil(self.bsLeDiscovery.centralManager, @"expected centralManager nil");
    XCTAssertNil(self.bsLeDiscovery.foundPeripherals, @"expected foundPeripherals nil");
    XCTAssertNil(self.bsLeDiscovery.connectedServices, @"expected connectedServices nil");
    XCTAssertNil(self.bsLeDiscovery.notificationCenter, @"expected notificationCenter nil");
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

// This test assumes iOS device will find at least one peripheral
// and the first is a Red Bear Lab Ble Shield
- (void)testFoundPeripherals {

    NSDictionary *bleDevices = [BSJSONParser dictFromJSONFile:@"bleDevices"];
    NSString *expectedIdentifier = bleDevices[@"redbearshield"][@"identifier"];
    NSString *expectedName = bleDevices[@"redbearshield"][@"name"];

    // using __block allows block to change bsLeDiscovery, set property foundPeripherals??
    __block BSLeDiscovery *bsLeDiscovery = [BSLeDiscovery sharedInstance];

    // http://stackoverflow.com/questions/10178293/how-to-get-list-of-available-bluetooth-devices?rq=1
    //[bsLeDiscovery startScanningForUUIDString:kRedBearLabBLEShieldServiceUUIDString];
    [bsLeDiscovery startScanningForUUIDString:nil];

    SHTestCaseBlock testBlock = ^(BOOL *didFinish) {

        NSLog(@"In testBlock. foundPeripherals: %@", bsLeDiscovery.foundPeripherals);

        if ( 1 <= [bsLeDiscovery.foundPeripherals count]) {
            CBPeripheral *peripheral = [bsLeDiscovery.foundPeripherals firstObject];

            XCTAssertEqualObjects(expectedIdentifier,
                                  [peripheral.identifier UUIDString],
                                  @"expected first found peripheral UUIDString");
            XCTAssertEqualObjects(expectedName,
                                  peripheral.name,
                                  @"expected first found peripheral name");

            // dereference the pointer to set the BOOL value
            *didFinish = YES;
        }
    };

    // SH_performAsyncTestsWithinBlock calls testBlock
    // and supplies its argument, a pointer to BOOL didFinish.
    // SH_performAsyncTestsWithinBlock keeps calling the block
    // until the block sets didFinish YES or the test times out.
    [self SH_performAsyncTestsWithinBlock:testBlock withTimeout:60.0];
}

#pragma mark - test Connect/Disconnect
/*
 // This test runs asynchronously, and is preferable to blocking the main thread.
 // It's not working, so comment it out for now.
 // TODO: figure out why centralManager status never says powered on.
 // This test assumes iOS device will find at least one peripheral, and tries to connect.
- (void)testConnectAsync {
    
    // using __block allows block to change bsLeDiscovery
    __block BSLeDiscovery *bsLeDiscovery = [BSLeDiscovery sharedInstance];

    SHTestCaseBlock testBlock = ^(BOOL *didFinish) {
        
        NSLog(@"In testBlock. *didFinish: %hhd", *didFinish);
        
        // wait for centralManager to become powered on.
        // http://stackoverflow.com/questions/17118534/when-would-cbcentralmanagers-state-ever-be-powered-on-but-still-give-me-a-not?rq=1
        if(CBCentralManagerStatePoweredOn == bsLeDiscovery.centralManager.state) {
            // centralManager is powered on, ok to scan and retrieve
            NSLog(@"CBCentralManagerStatePoweredOn");
            
            if(!bsLeDiscovery.foundPeripherals
               || ([@[]  isEqual: bsLeDiscovery.foundPeripherals])) {
                [bsLeDiscovery startScanningForUUIDString:nil];
            } else {
                // foundPeripherals has at least one peripheral
                CBPeripheral *peripheral = [bsLeDiscovery.foundPeripherals firstObject];

                // TODO: Call connectPeripheral only once?
                [bsLeDiscovery connectPeripheral:peripheral];
                
                if (CBPeripheralStateConnected == peripheral.state) {
                    XCTAssert((CBPeripheralStateConnected == peripheral.state), @"");
                    // dereference the pointer to set the BOOL value
                    *didFinish = YES;
                }
            }
        } else {
            NSLog(@"still not powered on");
        }
    };
    
    // SH_performAsyncTestsWithinBlock calls testBlock
    // and supplies its argument, a pointer to BOOL didFinish.
    // SH_performAsyncTestsWithinBlock keeps calling the block
    // until the block sets didFinish YES or the test times out.
    [self SH_performAsyncTestsWithinBlock:testBlock withTimeout:15.0];
}
*/

/*
 // This test blocks the main thread.
 // It's not working, so comment it out for now.
 // TODO: figure out why centralManager status never says powered on.
- (void)testConnect {
    
    BSLeDiscovery *bsLeDiscovery = [BSLeDiscovery sharedInstance];
    CBPeripheral *peripheral = nil;

    BOOL didCallConnect = NO;
    BOOL isConnected = NO;
    
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:15];
    
    while (!isConnected
           && (NSOrderedDescending != [[NSDate date] compare: timeoutDate]) ) {
        NSLog(@"not timed out");
        sleep(1);

        if(CBCentralManagerStatePoweredOn != bsLeDiscovery.centralManager.state) {
            NSLog(@"still not powered on");
            NSLog(@"state %d", bsLeDiscovery.centralManager.state);
        } else {
            // centralManager is powered on, ok to scan and retrieve
            // http://stackoverflow.com/questions/17118534/when-would-cbcentralmanagers-state-ever-be-powered-on-but-still-give-me-a-not?rq=1
            NSLog(@"CBCentralManagerStatePoweredOn");
        [bsLeDiscovery startScanningForUUIDString:nil];

            if(!bsLeDiscovery.foundPeripherals
               || ([@[]  isEqual: bsLeDiscovery.foundPeripherals])) {
                NSLog(@"foundPeripherals nil or empty");
                //[bsLeDiscovery startScanningForUUIDString:nil];
            } else {
                // foundPeripherals has at least one peripheral
                NSLog(@"foundPeripherals has at least one peripheral");
                peripheral = [bsLeDiscovery.foundPeripherals firstObject];
                
                if (!didCallConnect) {
                    NSLog(@"calling connectPeripheral");
                    [bsLeDiscovery connectPeripheral:peripheral];
                    didCallConnect = YES;
                }
                
                if (CBPeripheralStateConnected == peripheral.state) {
                    // dereference the pointer to set the BOOL value
                    isConnected = YES;
                }
            }
        }
    }
    XCTAssert((CBPeripheralStateConnected == peripheral.state), @"");
}
 */

# pragma mark - test post notifications
- (void)testCentralManagerOffDidUpdateStatePostsBleDiscoveryDidRefreshNotification
{
    id mockNotificationCenter = [OCMockObject mockForClass:[NSNotificationCenter class]];

    BSStubCBCentralManager *stubCentralManager = [[BSStubCBCentralManager alloc] init];
    stubCentralManager.state = CBCentralManagerStatePoweredOff;

    self.bsLeDiscovery = [[BSLeDiscovery alloc]
                          initWithCentralManager:(CBCentralManager *)stubCentralManager
                          foundPeripherals:nil
                          connectedServices:nil
                          notificationCenter:mockNotificationCenter];

    [[mockNotificationCenter expect] postNotificationName:kBleDiscoveryDidRefreshNotification
                                                   object:self.bsLeDiscovery
                                                 userInfo:nil];

    [self.bsLeDiscovery centralManagerDidUpdateState:(CBCentralManager *)stubCentralManager];
    
    // Verify all stubbed or expected methods were called.
    [mockNotificationCenter verify];
}

- (void)testCentralManagerOffDidUpdateStatePostsBleDiscoveryStatePoweredOffNotification
{
    // use nice mock to ignore un-expected method calls
    id mockNotificationCenter = [OCMockObject niceMockForClass:[NSNotificationCenter class]];

    BSStubCBCentralManager *stubCentralManager = [[BSStubCBCentralManager alloc] init];
    stubCentralManager.state = CBCentralManagerStatePoweredOff;

    self.bsLeDiscovery = [[BSLeDiscovery alloc]
                          initWithCentralManager:(CBCentralManager *)stubCentralManager
                          foundPeripherals:nil
                          connectedServices:nil
                          notificationCenter:mockNotificationCenter];

    [[mockNotificationCenter expect] postNotificationName:kBleDiscoveryStatePoweredOffNotification
                                                   object:self.bsLeDiscovery
                                                 userInfo:nil];

    [self.bsLeDiscovery centralManagerDidUpdateState:(CBCentralManager *)stubCentralManager];
    
    // Verify all stubbed or expected methods were called.
    [mockNotificationCenter verify];
}

- (void)testCentralManagerOnDidUpdateStatePostsBleDiscoveryDidRefreshNotification
{
    id mockNotificationCenter = [OCMockObject mockForClass:[NSNotificationCenter class]];

    BSStubCBCentralManager *stubCentralManager = [[BSStubCBCentralManager alloc] init];
    stubCentralManager.state = CBCentralManagerStatePoweredOn;

    self.bsLeDiscovery = [[BSLeDiscovery alloc]
                          initWithCentralManager:(CBCentralManager *)stubCentralManager
                          foundPeripherals:nil
                          connectedServices:nil
                          notificationCenter:mockNotificationCenter];

    [[mockNotificationCenter expect] postNotificationName:kBleDiscoveryDidRefreshNotification
                                                   object:self.bsLeDiscovery
                                                 userInfo:nil];

    [self.bsLeDiscovery centralManagerDidUpdateState:(CBCentralManager *)stubCentralManager];
    
    // Verify all stubbed or expected methods were called.
    [mockNotificationCenter verify];
}

- (void)testCentralManagerDidConnectPeripheralPostsBleDiscoveryDidConnectPeripheralNotification
{
    id mockNotificationCenter = [OCMockObject mockForClass:[NSNotificationCenter class]];

    BSStubCBCentralManager *stubCentralManager = [[BSStubCBCentralManager alloc] init];
    stubCentralManager.state = CBCentralManagerStatePoweredOn;

    self.bsLeDiscovery = [[BSLeDiscovery alloc]
                          initWithCentralManager:(CBCentralManager *)stubCentralManager
                          foundPeripherals:nil
                          connectedServices:nil
                          notificationCenter:mockNotificationCenter];

    // Instantiating a CBPeripheral made program crash.
    // So use an NSObject and cast it.
    // CBPeripheral *fakePeripheral = [[CBPeripheral alloc] init];
    NSObject *fakePeripheral = [[NSObject alloc] init];
    NSDictionary *fakeUserInfo = @{ @"peripheral" : fakePeripheral};
    [[mockNotificationCenter expect]
     postNotificationName:kBleDiscoveryDidConnectPeripheralNotification
     object:self.bsLeDiscovery
     userInfo:fakeUserInfo];

    [self.bsLeDiscovery centralManager:(CBCentralManager *)stubCentralManager
                  didConnectPeripheral:(CBPeripheral *)fakePeripheral];

    // Verify all stubbed or expected methods were called.
    [mockNotificationCenter verify];
}

@end
