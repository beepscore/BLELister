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
        NSLog(@"CBCentralManager powered on, calling scanForPeripheralsWithServices.");
        [self scanForPeripheralsWithServices:serviceUUIDs options:options];
    } else {
        NSLog(@"CBCentralManager not powered on, didn't scan.");
    }
}

@end
