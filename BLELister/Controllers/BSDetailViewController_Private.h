//
//  BSDetailViewController_Private.h
//  BLELister
//
//  Created by Steve Baker on 10/11/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import "BSDetailViewController.h"

@interface BSDetailViewController () {
}

// viewDidLoad sets self.notificationCenter. Unit test can set it to a mock notificationCenter.
@property (nonatomic, strong) NSNotificationCenter *notificationCenter;

- (void)discoveryDidConnectPeripheralWithNotification:(NSNotification *)notification;

- (void)updateUIOnMainQueue;

@end
