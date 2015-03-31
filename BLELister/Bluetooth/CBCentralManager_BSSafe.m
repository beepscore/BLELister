//
//  CBCentralManager_BSSafe.m
//  BLELister
//
//  Created by Steve Baker on 11/7/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import "CBCentralManager_BSSafe.h"

@implementation CBCentralManager (BSSafe)

- (void)safeScanForPeripheralsWithServices:(NSArray *)serviceUUIDs
                                   options:(NSDictionary *)options {
    if(CBCentralManagerStatePoweredOn == self.state) {
        [self scanForPeripheralsWithServices:serviceUUIDs options:options];
    } else {
        DDLogVerbose(@"CBCentralManager not powered on, didn't scan.");
    }
}

@end
