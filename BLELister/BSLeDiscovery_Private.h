//
//  BSLeDiscovery_Private.h
//  BLELister
//
//  Created by Steve Baker on 9/27/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import "BSLeDiscovery.h"

/// Expose properties for use by unit tests
/// Declare "private" methods for use by unit tests.
/// Use extension () instead of category (Tests) and import in BSLeDiscovery.m
/// This way, compiler checks for incomplete implementation
/// Reference
/// http://stackoverflow.com/questions/1098550/unit-testing-of-private-methods-in-xcode
/// http://lisles.net/accessing-private-methods-and-properties-in-objc-unit-tests/

@interface BSLeDiscovery ()

/**
 designated initializer
 @param aCentralManager
 sets ivar centralManager
 @param aFoundPeripherals
 sets property self.foundPeripherals
 @param aConnectedServices
 sets property self.connectedServices
 @return a BSLeDiscovery, generally used as a singleton
 */
- (id)initWithCentralManager:(CBCentralManager *)aCentralManager
            foundPeripherals:(NSMutableArray *)aFoundPeripherals
           connectedServices:(NSMutableArray *)aConnectedServices;
@end
