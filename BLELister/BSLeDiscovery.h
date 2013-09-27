//
//  BSLeDiscovery.h
//  BLELister
//
//  Created by Steve Baker on 9/26/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//  Portions copyright (C) 2011 Apple Inc. All Rights Reserved.
//
// Abstract: Scan for and discover nearby LE peripherals with the matching service UUID.

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

// UI protocols
@protocol BSLeDiscoveryDelegate <NSObject>
- (void) discoveryDidRefresh;
- (void) discoveryStatePoweredOff;
@end


// Discovery class
@interface BSLeDiscovery : NSObject

+ (id) sharedInstance;

// UI controls
@property (nonatomic, assign) id<BSLeDiscoveryDelegate>           discoveryDelegate;

// Actions
- (void) startScanningForUUIDString:(NSString *)uuidString;
- (void) stopScanning;

- (void) connectPeripheral:(CBPeripheral*)peripheral;
- (void) disconnectPeripheral:(CBPeripheral*)peripheral;

// Access to the devices
@property (retain, nonatomic) NSMutableArray    *foundPeripherals;
// Array of LeTemperatureAlarmService
@property (retain, nonatomic) NSMutableArray	*connectedServices;
@end
