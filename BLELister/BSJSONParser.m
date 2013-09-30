//
//  BSJSONParser.m
//  BLELister
//
//  Created by Steve Baker on 9/29/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import "BSJSONParser.h"

@implementation BSJSONParser

+ (NSArray *)arrayFromJSON:(NSString *)aJSON {

    // don't attempt to parse nil argument, that will crash
    if (!aJSON) {
        return @[];
    }

    // http://stackoverflow.com/questions/8606444/how-do-i-convert-a-json-string-to-a-dictionary-in-ios5
    NSData *jsonData = [aJSON dataUsingEncoding:NSUTF8StringEncoding];

    NSArray *array = [NSJSONSerialization
                      JSONObjectWithData:jsonData
                      options: NSJSONReadingMutableContainers
                      error: nil];
    return array;
}

+ (NSArray *)arrayFromJSONFile:(NSString *)aJSONFileName {
    return @[];
}

+ (NSDictionary *)dictFromJSON:(NSString *)aJSON {

    // don't attempt to parse nil argument, that will crash
    if (!aJSON) {
        return @{};
    }

    // http://stackoverflow.com/questions/8606444/how-do-i-convert-a-json-string-to-a-dictionary-in-ios5
    NSData *jsonData = [aJSON dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *dictionary = [NSJSONSerialization
                      JSONObjectWithData:jsonData
                      options: NSJSONReadingMutableContainers
                      error: nil];
    return dictionary;
}

+ (NSDictionary *)dictFromJSONFile:(NSString *)aJSONFileName {
    return @{};
}

+ (NSString *)JSONStringFromFile:(NSString *)aJSONFileName {
    return @"";
}

@end
