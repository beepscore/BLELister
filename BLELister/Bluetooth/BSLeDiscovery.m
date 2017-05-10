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
#import "BSBlePeripheral.h"
#import "CBCentralManager_BSSafe.h"

@implementation BSLeDiscovery

// http://stackoverflow.com/questions/5720029/create-singleton-using-gcds-dispatch-once-in-objective-c
+ (instancetype)sharedInstance {
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
                          foundPeripherals:@[]
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
- (instancetype)initWithCentralManager:(CBCentralManager *)aCentralManager
                      foundPeripherals:(NSArray *)aFoundPeripherals
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
- (instancetype) init {
    // call designated initializer
    return [self initWithCentralManager:nil
                       foundPeripherals:@[]
                      connectedServices:[[NSMutableArray alloc] init]
                     notificationCenter:nil];
}

#pragma mark - Restoring
// Settings
// Reload from file
- (void) loadSavedDevices {
    NSArray	*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:kStoredDevices];

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

- (void) addSavedDevice:(CBUUID *)uuid {
    NSArray			*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:kStoredDevices];
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
    [[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:kStoredDevices];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) removeSavedDevice:(CBUUID *)uuid {
    NSArray			*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:kStoredDevices];
    NSMutableArray	*newDevices		= nil;

    if ([storedDevices isKindOfClass:[NSArray class]]) {
        newDevices = [NSMutableArray arrayWithArray:storedDevices];

        if (uuid) {
            [newDevices removeObject:uuid];
        }
        /* Store */
        [[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:kStoredDevices];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Discovery
- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs
                               options:(NSDictionary *)options {
    [self.centralManager safeScanForPeripheralsWithServices:serviceUUIDs options:options];
}

- (void) startScanningForUUIDString:(NSString *)uuidString {
    NSDictionary *options = @{
                              CBCentralManagerScanOptionAllowDuplicatesKey:@NO
                              };
    if ((!uuidString) || [@"" isEqualToString:uuidString]) {
        // BLE requires device, not simulator
        // If running simulator, app crashes here with "bad access".
        // Also Apple says services argument nil works, but is not recommended.
        [self.centralManager safeScanForPeripheralsWithServices:nil options:options];
    } else {
        CBUUID *uuid = [CBUUID UUIDWithString:uuidString];
        NSArray *uuidArray = @[uuid];

        // NOTE: scanForPeripheralsWithServices:options:
        // services is array of CBUUID not NSUUID
        // Applications that have specified the bluetooth-central background mode
        // are allowed to scan while backgrounded, with two caveats:
        // the scan must specify one or more service types in serviceUUIDs,
        // and the CBCentralManagerScanOptionAllowDuplicatesKey scan option will be ignored.
        [self.centralManager safeScanForPeripheralsWithServices:uuidArray options:options];
    }
}

- (void) stopScanning {
    [self.centralManager stopScan];
}

#pragma mark - Connect/Disconnect
- (void) connectPeripheral:(CBPeripheral*)peripheral {
    if (peripheral.state == CBPeripheralStateDisconnected) {
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void) disconnectPeripheral:(CBPeripheral*)peripheral {
    [self.centralManager cancelPeripheralConnection:peripheral];
}

#pragma mark - CBCentralManagerDelegate
// https://developer.apple.com/library/ios/documentation/CoreBluetooth/Reference/CBCentralManagerDelegate_Protocol/translated_content/CBCentralManagerDelegate.html

// CBCentralManagerDelegate required method
- (void) centralManagerDidUpdateState:(CBCentralManager *)central {
    static CBManagerState previousState = -1;

    // TODO: Do we need to get main queue, in case centralManager is using non-main queue?
    NSLog(@"%@ CBCentralManagerState %ld", central, central.state);

    switch ([central state]) {

        case CBManagerStateUnknown:
        {
            /* Bad news, let's wait for another event. */
            break;
        }
        case CBManagerStateResetting:
        {
            [self clearDevices];
            [self.notificationCenter postNotificationName:kBleDiscoveryDidRefreshNotification
                                                   object:self
                                                 userInfo:nil];
            //[peripheralDelegate alarmServiceDidReset];
            break;
        }
            
        case CBManagerStateUnsupported:
        {
            // original code didn't list this case and xcode warned
            // so list case to silence warning, but don't do anything
            break;
        }
            
        case CBManagerStateUnauthorized:
        {
            /* Tell user the app is not allowed. */
            break;
        }
            
        case CBManagerStatePoweredOff:
        {
            [self clearDevices];
            [self.notificationCenter postNotificationName:kBleDiscoveryDidRefreshNotification
                                                   object:self
                                                 userInfo:nil];
            /* Tell user to power ON BT for functionality, but not on first run - the Framework will alert in that instance. */
            // cast -1 to CBCentralManagerState to eliminate warning
            if (previousState != (CBManagerState)-1) {
                [self.notificationCenter postNotificationName:kBleDiscoveryStatePoweredOffNotification
                                                       object:self
                                                     userInfo:nil];
            }
            break;
        }
            
        case CBManagerStatePoweredOn:
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
                  error:(NSError *)error {
    /* Delete from plist. */
    [self removeSavedDevice:uuid];
}

- (void) centralManager:(CBCentralManager *)central
   didConnectPeripheral:(CBPeripheral *)peripheral {

    [self updatePeripherals:self.foundPeripherals
                 peripheral:peripheral];
    
    NSDictionary *userInfo = @{ @"peripheral" : peripheral };
    [self.notificationCenter postNotificationName:kBleDiscoveryDidConnectPeripheralNotification
                                           object:self
                                         userInfo:userInfo];
    [peripheral setDelegate:self];

    // must be connected to call readRSSI
    // could set timer to repeatedly call readRSSI
    // readRSSI calls back delegate method peripheral:didReadRSSI:error:
    [peripheral readRSSI];

    // discoverServices calls back delegate method peripheral:didDiscoverServices:
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {

    NSLog(@"Attempted connection to peripheral %@ failed: %@", [peripheral name], [error localizedDescription]);
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {

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
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    
    [self updatePeripherals:self.foundPeripherals
                 peripheral:peripheral];
    
    // Argument RSSI may be non-nil even when peripheral.RSSI is nil
    NSDictionary *userInfo = @{@"central" : central,
                               @"peripheral" : peripheral,
                               @"advertisementData" : advertisementData,
                               @"RSSI" : RSSI };
    
    // centralManager may be calling back from the main queue or a background queue.
    // Post notification on current thread, whether it's main or a background thread.
    // Observers will be notified on current thread.
    // Let each observer decide if it will respond on current thread or not.
    // For example a view controller might want to get the main queue and then update UI.
    [self.notificationCenter postNotificationName:kBleDiscoveryDidRefreshNotification
                                           object:self
                                         userInfo:userInfo];
}

#pragma mark -
- (void) clearDevices {
    self.foundPeripherals = @[];
    // TODO: reset each service before removing it? Reference Apple TemperatureSensor project
    [self.connectedServices removeAllObjects];
}

#pragma mark - CBPeripheralDelegate
// CBPeripheralDelegate has no required methods
// https://developer.apple.com/library/ios/documentation/CoreBluetooth/Reference/CBPeripheralDelegate_Protocol/translated_content/CBPeripheralDelegate.html

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error {

    NSLog(@"%@", peripheral);
    if (error) {
        NSLog(@"%@", error);
    } else {
        
        for (CBService *service in peripheral.services) {
            if (![self.connectedServices containsObject:service]) {
                NSLog(@"service.UUID %@", service.UUID);
                [self.connectedServices addObject:service];
                
                // discoverCharacteristics:forService: calls delegate method
                // peripheral:didDiscoverCharacteristicsForService:error:
                [peripheral discoverCharacteristics:nil forService:service];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error {

    NSLog(@"peripheral %@", peripheral);
    NSLog(@"service %@", service);
    if (error) {
        NSLog(@"%@", error);
    } else {
        
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            NSLog(@"chacteristic.UUID %@", characteristic.UUID);
            // readValueForCharacteristic: reads once, doesn't subscribe
            // calls delegate method
            // peripheral:didUpdateValueForCharacteristic:error:
            [peripheral readValueForCharacteristic:characteristic];
            
            // TODO:
            // setNotifyValue:forCharacteristic: requests peripheral start providing notifications
            // calls delegate method
            // peripheral:didUpdateNotificationStateForCharacteristic:error:
            // if peripheral starts notifications, whenever value changes it calls
            // peripheral:didUpdateValueForCharacteristic:error:
            // e.g.
            // [self.polarH7HRMPeripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {

    NSLog(@"peripheral %@", peripheral);
    NSLog(@"chacteristic %@", characteristic);

    if (error) {
        // Some characteristics aren't readable, give error
        // Error Domain=CBATTErrorDomain Code=2 "Reading is not permitted."
        NSLog(@"%@", error);
    } else {
        NSLog(@"value %@", [characteristic value]);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
       didReadRSSI:(NSNumber *)RSSI
             error:(NSError *)error {

    if (RSSI && !error) {
        [self updatePeripherals:self.foundPeripherals
                     peripheral:peripheral
                           RSSI:RSSI];
    }

    NSMutableDictionary *mutableUserInfo = [NSMutableDictionary
                                            dictionaryWithDictionary: @{@"peripheral" : peripheral}];
    if (RSSI) {
        [mutableUserInfo setValue:RSSI forKey:@"RSSI"];
    }
    if (error) {
        [mutableUserInfo setValue:error forKey:@"error"];
    }
    // NSMutableDictionary not thread safe, so copy to NSDictionary
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:mutableUserInfo];
    
    // Post notification on current thread, whether it's main or a background thread.
    // Observers will be notified on current thread.
    // Let each observer decide if it will respond on current thread or not.
    // For example a view controller might want to get the main queue and then update UI.
    [self.notificationCenter postNotificationName:kBleDiscoveryDidReadRSSINotification
                                           object:self
                                         userInfo:userInfo];
}

#pragma mark -
- (void)updatePeripherals:(NSArray *)peripherals
               peripheral:(CBPeripheral *)peripheral {

    BOOL didFindPeripheral = NO;

    for (BSBlePeripheral *bsBlePeripheral in peripherals) {
        if (bsBlePeripheral.peripheral.identifier == peripheral.identifier) {
            bsBlePeripheral.peripheral = peripheral;
            didFindPeripheral = YES;
            // exit loop
            break;
        }
    }

    if (!didFindPeripheral) {
        BSBlePeripheral *bsBlePeripheral = [[BSBlePeripheral alloc] init];
        bsBlePeripheral.peripheral = peripheral;
        self.foundPeripherals = [self.foundPeripherals arrayByAddingObject:bsBlePeripheral];
    }
}

- (void)updatePeripherals:(NSArray *)peripherals
               peripheral:(CBPeripheral *)peripheral
                     RSSI:(NSNumber *)RSSI {
    for (BSBlePeripheral *bsBlePeripheral in peripherals) {
        if (bsBlePeripheral.peripheral.identifier == peripheral.identifier) {
            bsBlePeripheral.RSSI = RSSI;
            // exit loop
            break;
        }
    }
}

@end
