//
//  BSStubCBCentralManager.h
//  BLELister
//
//  Created by Steve Baker on 10/12/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

/**
 BSStubCBCentralManager stubs a minimal subset of CBCentralManager for use by unit tests.
 Reference
 http://martinfowler.com/articles/mocksArentStubs.html
 */

#import <CoreBluetooth/CBCentralManager.h>

@interface BSStubCBCentralManager : NSObject

// BSStubCBCentralManager state is readwrite so we can set it for unit tests
// CBCentralManager state is readonly.
@property(readwrite) enum CBManagerState state;

// add delegate property so unit tests can set it
@property(weak, nonatomic) id<CBCentralManagerDelegate> delegate;

- (NSArray *)retrieveConnectedPeripheralsWithServices:(NSArray *)serviceUUIDs;

@end
