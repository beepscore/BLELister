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


@interface BSLeDiscovery () <CBCentralManagerDelegate, CBPeripheralDelegate> {
    CBCentralManager *centralManager;
    BOOL pendingInit;
}
@end


@implementation BSLeDiscovery

@synthesize foundPeripherals;
@synthesize connectedServices;
@synthesize discoveryDelegate;

#pragma mark - Init
+ (id) sharedInstance
{
    static BSLeDiscovery	*this = nil;

    if (!this)
        this = [[BSLeDiscovery alloc] init];

    return this;
}


- (id) init
{
    self = [super init];
    if (self) {
        pendingInit = YES;
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];

        foundPeripherals = [[NSMutableArray alloc] init];
        connectedServices = [[NSMutableArray alloc] init];
    }
    return self;
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

        if (!uuid)
            continue;

        if (![uuid isKindOfClass:[CBUUID class]])
            continue;

        NSArray *services = @[uuid];
        [centralManager retrieveConnectedPeripheralsWithServices:services];
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
- (void) startScanningForUUIDString:(NSString *)uuidString
{
    CBUUID *uuid = [CBUUID UUIDWithString:uuidString];
    NSArray *uuidArray = @[uuid];
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                        forKey:CBCentralManagerScanOptionAllowDuplicatesKey];

    [centralManager scanForPeripheralsWithServices:uuidArray options:options];
}

- (void) stopScanning
{
    [centralManager stopScan];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (![foundPeripherals containsObject:peripheral]) {
              [foundPeripherals addObject:peripheral];
              [discoveryDelegate discoveryDidRefresh];
    }
}

#pragma mark - Connection/Disconnection
- (void) connectPeripheral:(CBPeripheral*)peripheral
{
    if (peripheral.state == CBPeripheralStateDisconnected) {
        [centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
    [centralManager cancelPeripheralConnection:peripheral];
}

#pragma mark - CBCentralManagerDelegate
// https://developer.apple.com/library/ios/documentation/CoreBluetooth/Reference/CBCentralManagerDelegate_Protocol/translated_content/CBCentralManagerDelegate.html

/* In iOS 7, can replace retrieveConnectedPeripherals: and didRetrieveConnectedPeripherals:
   with retrieveConnectedPeripheralsWithServices:
- (void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    CBPeripheral	*peripheral;

    // Add to list.
    for (peripheral in peripherals) {
        [central connectPeripheral:peripheral options:nil];
    }
    [discoveryDelegate discoveryDidRefresh];
}
*/

/*
 In iOS 7, can replace retrievePeripheral: and didRetrievePeriperal: with retrievePeripheralsWithIdentifiers
- (void) centralManager:(CBCentralManager *)central didRetrievePeripheral:(CBPeripheral *)peripheral
{
    [central connectPeripheral:peripheral options:nil];
    [discoveryDelegate discoveryDidRefresh];
}
*/

- (void) centralManager:(CBCentralManager *)central didFailToRetrievePeripheralForUUID:(CBUUID *)uuid error:(NSError *)error
{
    /* Delete from plist. */
    [self removeSavedDevice:uuid];
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
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

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Attempted connection to peripheral %@ failed: %@", [peripheral name], [error localizedDescription]);
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
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
    [foundPeripherals removeAllObjects];

    /*
    LeTemperatureAlarmService *service;
    for (service in connectedServices) {
        [service reset];
    }
    */
    [connectedServices removeAllObjects];
}

// CBCentralManagerDelegate required method
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    static CBCentralManagerState previousState = -1;

    switch ([centralManager state]) {
        case CBCentralManagerStatePoweredOff:
            {
                [self clearDevices];
                [discoveryDelegate discoveryDidRefresh];

                /* Tell user to power ON BT for functionality, but not on first run - the Framework will alert in that instance. */
                // cast -1 to CBCentralManagerState to eliminate warning
                if (previousState != (CBCentralManagerState)-1) {
                    [discoveryDelegate discoveryStatePoweredOff];
                }
                break;
            }

        case CBCentralManagerStateUnauthorized:
            {
                /* Tell user the app is not allowed. */
                break;
            }

        case CBCentralManagerStateUnknown:
            {
                /* Bad news, let's wait for another event. */
                break;
            }

        case CBCentralManagerStatePoweredOn:
            {
                pendingInit = NO;
                [self loadSavedDevices];

                //FIXME:
                // retrieveConnectedPeripherals deprecated in iOS 7.
                //[centralManager retrieveConnectedPeripherals];
                NSArray *peripherals = [centralManager retrieveConnectedPeripheralsWithServices:nil];

                // Add to list.
                for (CBPeripheral *peripheral in peripherals) {
                    [central connectPeripheral:peripheral options:nil];
                }
                [discoveryDelegate discoveryDidRefresh];
                break;
            }

        case CBCentralManagerStateResetting:
            {
                [self clearDevices];
                [discoveryDelegate discoveryDidRefresh];
                //[peripheralDelegate alarmServiceDidReset];

                pendingInit = YES;
                break;
            }

        case CBCentralManagerStateUnsupported:
            {
                // original code didn't list this case and xcode warned
                // so list case to silence warning, but don't do anything
            }
    }

    previousState = [centralManager state];
}

#pragma mark - CBPeripheralDelegate
// CBPeripheralDelegate has no required methods
// https://developer.apple.com/library/ios/documentation/CoreBluetooth/Reference/CBPeripheralDelegate_Protocol/translated_content/CBPeripheralDelegate.html

@end
