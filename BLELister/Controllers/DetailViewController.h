//
//  DetailViewController.h
//  BLELister
//
//  Created by Steve Baker on 5/10/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSDate *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

