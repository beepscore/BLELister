//
//  BSLeDiscovery.h
//  BLELister
//
//  Created by Steve Baker on 9/26/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//  Portions copyright (C) 2011 Apple Inc. All Rights Reserved.
//
// Abstract: Scan for and discover nearby LE peripherals with the matching service UUID.

/**
 BSLeDiscovery posts notifications.
 This way, the app can instantiate one BSLeDiscovery
 to support multilple objects (e.g. view controllers)
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


// Discovery class
@interface BSLeDiscovery : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

/**
 sets property self.notificationCenter to [NSNotificationCenter defaultCenter]
 @return a shared instance, not strictly enforced as a singleton
 */
+ (id) sharedInstance;

@property (nonatomic, strong) CBCentralManager *centralManager;

// Actions
- (void) startScanningForUUIDString:(NSString *)uuidString;
- (void) stopScanning;

- (void) connectPeripheral:(CBPeripheral*)peripheral;
- (void) disconnectPeripheral:(CBPeripheral*)peripheral;

// Access to the devices
@property (strong, nonatomic) NSMutableArray *foundPeripherals;
// Array of LeTemperatureAlarmService
@property (strong, nonatomic) NSMutableArray *connectedServices;

@end
