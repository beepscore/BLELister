//
//  DetailViewController_Private.h
//  BLELister
//
//  Created by Steve Baker on 10/11/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () {
}

// viewDidLoad sets self.notificationCenter. Unit test can set it to a mock notificationCenter.
@property (nonatomic, strong) NSNotificationCenter *notificationCenter;
@property (nonatomic, strong) NSNumber *RSSI;

- (void)discoveryDidConnectPeripheralWithNotification:(NSNotification *)notification;
- (void)discoveryDidDisconnectPeripheralWithNotification:(NSNotification *)notification;

- (void)updateUIOnMainQueue;

@end
