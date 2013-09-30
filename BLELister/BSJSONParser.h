//
//  BSJSONParser.h
//  BLELister
//
//  Created by Steve Baker on 9/29/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSJSONParser : NSObject

+ (NSArray *)arrayFromJSON:(NSString *)aJSON;
+ (NSArray *)arrayFromJSONFile:(NSString *)aJSONFileName;

+ (NSDictionary *)dictFromJSON:(NSString *)aJSON;
+ (NSDictionary *)dictFromJSONFile:(NSString *)aJSONFileName;

+ (NSString *)JSONStringFromFile:(NSString *)aJSONFileName;

@end
