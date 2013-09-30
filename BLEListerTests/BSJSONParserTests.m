//
//  BSJSONParserTests.m
//  BLELister
//
//  Created by Steve Baker on 9/29/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BSJSONParser.h"

@interface BSJSONParserTests : XCTestCase

@end

@implementation BSJSONParserTests

- (void)setUp {
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown {
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testArrayFromJSON {

    NSArray *expectedArray = @[@"Larry", @"Moe", @57, @"Curly"];

    NSString *testString = @"[\"Larry\", \"Moe\", 57, \"Curly\"]";
    NSArray *actualArray = [BSJSONParser arrayFromJSON:testString];
    
    XCTAssertEqualObjects(expectedArray, actualArray, @"");
}

- (void)testArrayFromJSONEmpty {

    NSArray *expectedArray = @[];

    NSString *testString = @"";
    NSArray *actualArray = [BSJSONParser arrayFromJSON:testString];
    
    XCTAssertEqualObjects(expectedArray, actualArray, @"");
}

- (void)testArrayFromJSONFile {
    NSArray *expectedArray = @[@"Larry", @"Moe", @57, @"Curly"];

    NSArray *actualArray = [BSJSONParser arrayFromJSONFile:@"stubArray"];

    XCTAssertEqualObjects(expectedArray, actualArray, @"");
}

- (void)testDictFromJSON {

    NSDictionary *expectedDict = @{@"redbearshield":@{@"identifier":@"DDAB0207-5E10-2902-5B03-CA3F0F466B40", @"name":@"BLE Shield"},@"sensortag":@{@"identifier":@"B42E4E5D-B2D3-F03F-3139-7B735C8E8964",@"name":@"TI BLE Sensor Tag"}};

    NSString *testString = @"{\"redbearshield\":{\"identifier\":\"DDAB0207-5E10-2902-5B03-CA3F0F466B40\",\"name\":\"BLE Shield\"},\"sensortag\":{\"identifier\":\"B42E4E5D-B2D3-F03F-3139-7B735C8E8964\",\"name\":\"TI BLE Sensor Tag\"}}";
    NSDictionary *actualDict = [BSJSONParser dictFromJSON:testString];
    
    XCTAssertEqualObjects(expectedDict, actualDict, @"");
}

- (void)testDictFromJSONEmpty {

    NSDictionary *expectedDict = @{};

    NSString *testString = @"";
    NSDictionary *actualDict = [BSJSONParser dictFromJSON:testString];
    
    XCTAssertEqualObjects(expectedDict, actualDict, @"");
}

- (void)testDictFromJSONNil {
    NSDictionary *expectedDict = @{};
    NSDictionary *actualDict = [BSJSONParser dictFromJSON:nil];
    XCTAssertEqualObjects(expectedDict, actualDict, @"");
}

- (void)testDictFromJSONFile {
    NSDictionary *expectedDict = @{@"redbearshield":@{@"identifier":@"DDAB0207-5E10-2902-5B03-CA3F0F466B40", @"name":@"BLE Shield"},@"sensortag":@{@"identifier":@"B42E4E5D-B2D3-F03F-3139-7B735C8E8964",@"name":@"TI BLE Sensor Tag"}};

    NSDictionary *actualDict = [BSJSONParser dictFromJSONFile:@"bleDevices"];

    XCTAssertEqualObjects(expectedDict, actualDict, @"");
}

- (void)testJSONStringFromFile {
    NSString *expectedString = @"{\"redbearshield\":{\"identifier\":\"DDAB0207-5E10-2902-5B03-CA3F0F466B40\",\"name\":\"BLE Shield\"},\"sensortag\":{\"identifier\":\"B42E4E5D-B2D3-F03F-3139-7B735C8E8964\",\"name\":\"TI BLE Sensor Tag\"}}";
    NSString *actualString = [BSJSONParser JSONStringFromFile:@"bleDevices"];
    XCTAssertEqualObjects(expectedString, actualString, @"");
}

@end
