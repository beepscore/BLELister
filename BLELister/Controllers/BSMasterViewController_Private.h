//
//  BSMasterViewController_Private.h
//  BLELister
//
//  Created by Steve Baker on 10/11/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import "BSMasterViewController.h"

@interface BSMasterViewController () {
    NSMutableArray *_objects;
}

// viewDidLoad sets self.notificationCenter. Unit test can set it to a mock notificationCenter.
@property (nonatomic, strong) NSNotificationCenter *notificationCenter;

- (void) discoveryDidRefreshWithNotification:(NSNotification *)notification;
- (void)updateUIOnMainQueue;

@end
