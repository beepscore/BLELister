//
//  BSLeDiscoveryTests.m
//  BLEListerTests
//
//  Created by Steve Baker on 9/26/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BSLeDiscovery.h"

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

- (void)testSharedInstanceFoundPeriperals {
    self.bsLeDiscovery = [BSLeDiscovery sharedInstance];
    // Could reduce scope of this test by testing sharedInstance calls
    // designated initializer.
    XCTAssertNotNil(self.bsLeDiscovery.foundPeripherals,
                   @"expected sharedInstance sets foundPeripherals");
}

- (void)testSharedInstanceConnectedServices {
    self.bsLeDiscovery = [BSLeDiscovery sharedInstance];
    // Could reduce scope of this test by testing sharedInstance calls
    // designated initializer.
    XCTAssertNotNil(self.bsLeDiscovery.connectedServices,
                   @"expected sharedInstance sets connectedServices");
}

@end
