//
//  BSBlePeripheral.h
//  
//
//  Created by Steve Baker on 6/20/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/**
 * BSBlePeripheral is composed of a CBPeripheral and an RSSI.
 * This object can be used to replace
 * CBPeripheral method [peripheral RSSI], deprecated in iOS 8
 */
@interface BSBlePeripheral : NSObject
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSNumber *RSSI;
@end
