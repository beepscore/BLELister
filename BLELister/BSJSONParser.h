//
//  BSJSONParser.h
//  BLELister
//
//  Created by Steve Baker on 9/29/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSJSONParser : NSObject


/**
 @return an empty array if argument is nil
 */
+ (NSArray *)arrayFromJSON:(NSString *)aJSON;

/**
 @param aJSONFileName is first part of file name, omitting .json extension
 @return an empty array if argument is nil or empty string @""
 */
+ (NSArray *)arrayFromJSONFile:(NSString *)aJSONFileName;

/**
 @return an empty dictionary if argument is nil
 */
+ (NSDictionary *)dictFromJSON:(NSString *)aJSON;

/**
 @param aJSONFileName is first part of file name, omitting .json extension
 @return an empty dictionary if argument is nil
 */
+ (NSDictionary *)dictFromJSONFile:(NSString *)aJSONFileName;

/**
 @param aJSONFileName is first part of file name, omitting .json extension
 */
+ (NSString *)JSONStringFromFile:(NSString *)aJSONFileName;

@end
