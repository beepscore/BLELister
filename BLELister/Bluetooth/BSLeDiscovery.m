//
//  BSLeDiscovery.m
//  BLELister
//
//  Created by Steve Baker on 9/26/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//  Portions copyright (C) 2011 Apple Inc. All Rights Reserved.
//
// Abstract: Scan for and discover nearby LE peripherals with the matching service UUID.

#import "BSLeDiscovery.h"
#import "BSLeDiscovery_Private.h"
#import "BSBleConstants.h"
#import "CBCentralManager_BSSafe.h"

@implementation BSLeDiscovery

// http://stackoverflow.com/questions/5720029/create-singleton-using-gcds-dispatch-once-in-objective-c
+ (id)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{

        NSLog(@"This block should run only one time. &once: %p, once: %ld", &once, once);
        
        // self isn't complete yet, so at first set CBCentralManagerDelegate to nil
        // later code should set delegate to self
        CBCentralManager *aCentralManager = [[CBCentralManager alloc]
                                             initWithDelegate:nil
                                             queue:nil];
        // call designated initializer
        sharedInstance = [[self alloc]
                          initWithCentralManager:aCentralManager
                          foundPeripherals:[[NSMutableArray alloc] init]
                          connectedServices:[[NSMutableArray alloc] init]
                          notificationCenter:[NSNotificationCenter defaultCenter]];
        
        NSLog(@"[[BSLeDiscovery sharedInstance] %@", sharedInstance);
        NSLog(@"[[BSLeDiscovery sharedInstance] centralManager] %@",
              [sharedInstance centralManager]);
    });
    return sharedInstance;
}

#pragma mark - Initializers
// designated initializer
- (id)initWithCentralManager:(CBCentralManager *)aCentralManager
            foundPeripherals:(NSMutableArray *)aFoundPeripherals
           connectedServices:(NSMutableArray *)aConnectedServices
          notificationCenter:(NSNotificationCenter *)aNotificationCenter {

    // call super's designated intializer
    self = [super init];
    if (self) {
        self.centralManager = aCentralManager;
        self.centralManager.delegate = self;
        self.foundPeripherals = aFoundPeripherals;
        self.connectedServices = aConnectedServices;
        self.notificationCenter = aNotificationCenter;
    }
    return self;
}

// override superclass' designated initializer. Ref Hillegass pg 57
- (id) init {
    // call designated initializer
    return [self initWithCentralManager:nil
                       foundPeripherals:nil
                      connectedServices:nil
                     notificationCenter:nil];
}

#pragma mark - Restoring
// Settings
// Reload from file
- (void) loadSavedDevices
{
    NSArray	*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];

    if (![storedDevices isKindOfClass:[NSArray class]]) {
        NSLog(@"No stored array to load");
        return;
    }

    for (id uuid in storedDevices) {

        if (!uuid) {
            continue;
        }

        if (![uuid isKindOfClass:[CBUUID class]]) {
            continue;
        }

        NSArray *services = @[uuid];
        [self.centralManager retrieveConnectedPeripheralsWithServices:services];
    }
}


- (void) addSavedDevice:(CBUUID *)uuid
{
    NSArray			*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];
    NSMutableArray	*newDevices		= nil;

    if (![storedDevices isKindOfClass:[NSArray class]]) {
        NSLog(@"Can't find/create an array to store the uuid");
        return;
    }

    newDevices = [NSMutableArray arrayWithArray:storedDevices];

    if (uuid) {
        [newDevices addObject:uuid];
    }
    /* Store */
    [[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:@"StoredDevices"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void) removeSavedDevice:(CBUUID *)uuid
{
    NSArray			*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];
    NSMutableArray	*newDevices		= nil;

    if ([storedDevices isKindOfClass:[NSArray class]]) {
        newDevices = [NSMutableArray arrayWithArray:storedDevices];

        if (uuid) {
            [newDevices removeObject:uuid];
        }
        /* Store */
        [[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:@"StoredDevices"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Discovery
- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options
{
    [self.centralManager safeScanForPeripheralsWithServices:serviceUUIDs options:options];
}

- (void) startScanningForUUIDString:(NSString *)uuidString
{
    NSDictionary *options = @{
                              CBCentralManagerScanOptionAllowDuplicatesKey:[NSNumber numberWithBool:NO]
                              };
    if ((!uuidString) || [@"" isEqualToString:uuidString]) {
        // BLE requires device, not simulator
        // If running simulator, app crashes here with "bad access".
        // Also Apple says services argument nil works, but is not recommended.
        //[self.centralManager safeScanForPeripheralsWithServices:nil options:options];
        [self.centralManager scanForPeripheralsWithServices:nil options:options];
    } else {
        CBUUID *uuid = [CBUUID UUIDWithString:uuidString];
        NSArray *uuidArray = @[uuid];
        //[self.centralManager safeScanForPeripheralsWithServices:uuidArray options:options];

        // NOTE: scanForPeripheralsWithServices:options:
        // services is array of CBUUID not NSUUID
        // Applications that have specified the bluetooth-central background mode
        // are allowed to scan while backgrounded, with two caveats:
        // the scan must specify one or more service types in serviceUUIDs,
        // and the CBCentralManagerScanOptionAllowDuplicatesKey scan option will be ignored.
        [self.centralManager scanForPeripheralsWithServices:uuidArray options:options];
    }
}

- (void) stopScanning
{
    [self.centralManager stopScan];
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    if (![self.foundPeripherals containsObject:peripheral]) {
        [self.foundPeripherals addObject:peripheral];
        
        // Argument RSSI may be non-nil even when peripheral.RSSI is nil
        NSDictionary *userInfo = @{@"peripheral" : peripheral,
                                   @"advertisementData" : advertisementData,
                                   @"RSSI" : RSSI };
        [self.notificationCenter postNotificationName:kBleDiscoveryDidRefreshNotification
                                               object:self
                                             userInfo:userInfo];
    }
}

#pragma mark - Connection/Disconnection
- (void) connectPeripheral:(CBPeripheral*)peripheral
{
    if (peripheral.state == CBPeripheralStateDisconnected) {
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
    [self.centralManager cancelPeripheralConnection:peripheral];
}

#pragma mark - CBCentralManagerDelegate
// https://developer.apple.com/library/ios/documentation/CoreBluetooth/Reference/CBCentralManagerDelegate_Protocol/translated_content/CBCentralManagerDelegate.html

// CBCentralManagerDelegate required method
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    static CBCentralManagerState previousState = -1;

    NSLog(@"%@ state %d", central, central.state);

    switch ([central state]) {

        case CBCentralManagerStateUnknown:
        {
            /* Bad news, let's wait for another event. */
            break;
        }
        case CBCentralManagerStateResetting:
        {
            [self clearDevices];
            [self.notificationCenter postNotificationName:kBleDiscoveryDidRefreshNotification
                                                   object:self
                                                 userInfo:nil];
            //[peripheralDelegate alarmServiceDidReset];
            break;
        }
            
        case CBCentralManagerStateUnsupported:
        {
            // original code didn't list this case and xcode warned
            // so list case to silence warning, but don't do anything
            break;
        }
            
        case CBCentralManagerStateUnauthorized:
        {
            /* Tell user the app is not allowed. */
            break;
        }
            
        case CBCentralManagerStatePoweredOff:
        {
            [self clearDevices];
            [self.notificationCenter postNotificationName:kBleDiscoveryDidRefreshNotification
                                                   object:self
                                                 userInfo:nil];
            
            /* Tell user to power ON BT for functionality, but not on first run - the Framework will alert in that instance. */
            // cast -1 to CBCentralManagerState to eliminate warning
            if (previousState != (CBCentralManagerState)-1) {
                [self.notificationCenter postNotificationName:kBleDiscoveryStatePoweredOffNotification
                                                       object:self
                                                     userInfo:nil];
            }
            break;
        }
            
        case CBCentralManagerStatePoweredOn:
        {
            [self loadSavedDevices];
            
            //FIXME: specify services argument
            //NSArray *peripherals = [central retrieveConnectedPeripheralsWithServices:@[]];

            // Add to list.
//            for (CBPeripheral *peripheral in peripherals) {
//                // method documentation: Attempts to connect to a peripheral do not time out.
//                [central connectPeripheral:peripheral options:nil];
//            }
            [self.notificationCenter postNotificationName:kBleDiscoveryDidRefreshNotification
                                                   object:self
                                                 userInfo:nil];
            break;
        }
    }
    previousState = [self.centralManager state];
}

- (void) centralManager:(CBCentralManager *)central
didFailToRetrievePeripheralForUUID:(CBUUID *)uuid
                  error:(NSError *)error
{
    /* Delete from plist. */
    [self removeSavedDevice:uuid];
}

- (void) centralManager:(CBCentralManager *)central
   didConnectPeripheral:(CBPeripheral *)peripheral
{
    if (![self.foundPeripherals containsObject:peripheral]) {
        [self.foundPeripherals addObject:peripheral];
    }

    NSDictionary *userInfo = @{ @"peripheral" : peripheral };
    [self.notificationCenter postNotificationName:kBleDiscoveryDidConnectPeripheralNotification
                                           object:self
                                         userInfo:userInfo];
    /*
     LeTemperatureAlarmService	*service	= nil;

    // Create a service instance
    service = [[[LeTemperatureAlarmService alloc] initWithPeripheral:peripheral controller:peripheralDelegate] autorelease];
    [service start];

    if (![connectedServices containsObject:service])
              [connectedServices addObject:service];

    if ([foundPeripherals containsObject:peripheral])
          [foundPeripherals removeObject:peripheral];

    [peripheralDelegate alarmServiceDidChangeStatus:service];
    [discoveryDelegate discoveryDidRefresh];
    */
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    NSLog(@"Attempted connection to peripheral %@ failed: %@", [peripheral name], [error localizedDescription]);
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    NSDictionary *userInfo = nil;
    if (!error) {
        // don't attempt to add nil object to dictionary
        userInfo = @{ @"peripheral" : peripheral};
    } else {
        userInfo = @{ @"peripheral" : peripheral,
                      @"error" : error };
    }
    [self.notificationCenter postNotificationName:kBleDiscoveryDidDisconnectPeripheralNotification
                                           object:self
                                         userInfo:userInfo];
    /*
     LeTemperatureAlarmService	*service	= nil;

    for (service in connectedServices) {
        if ([service peripheral] == peripheral) {
            [connectedServices removeObject:service];
            [peripheralDelegate alarmServiceDidChangeStatus:service];
            break;
        }
    }

    [discoveryDelegate discoveryDidRefresh];
     */
}

- (void) clearDevices
{
    [self.foundPeripherals removeAllObjects];

    /*
    LeTemperatureAlarmService *service;
    for (service in connectedServices) {
        [service reset];
    }
    */
    [self.connectedServices removeAllObjects];
}

#pragma mark - CBPeripheralDelegate
// CBPeripheralDelegate has no required methods
// https://developer.apple.com/library/ios/documentation/CoreBluetooth/Reference/CBPeripheralDelegate_Protocol/translated_content/CBPeripheralDelegate.html

@end
