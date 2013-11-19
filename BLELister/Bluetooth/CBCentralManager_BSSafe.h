//
//  CBCentralManager_BSSafe.h
//  BLELister
//
//  Created by Steve Baker on 11/7/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//
//  CBCentralManager_BSSafe category adds "safe" methods.
//  These methods check CBCentralManager is powered on before scanning or retrieving
// http://stackoverflow.com/questions/17118534/when-would-cbcentralmanagers-state-ever-be-powered-on-but-still-give-me-a-not?rq=1

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBCentralManager (BSSafe)

/** 
 if CBCentralManager is powered on, scans for peripherals with services
 if CBCentralManager is not powered on, doesn't scan, writes to log.
 Reference Apple documentation CBCentralManager class reference
 Before you call CBCentralManager methods, the state of the central manager object must be powered on.
*/
- (void)safeScanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options;
@end
