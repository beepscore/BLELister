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
    if ((!aJSON) || [@"" isEqualToString:aJSON]) {
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
    NSString *JSONString = [BSJSONParser JSONStringFromFile:aJSONFileName];
    NSArray *array = [BSJSONParser arrayFromJSON:JSONString];
    return array;
}

+ (NSDictionary *)dictFromJSON:(NSString *)aJSON {

    // don't attempt to parse nil argument, that will crash
    if ((!aJSON) || [@"" isEqualToString:aJSON]) {
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
    NSString *JSONString = [BSJSONParser JSONStringFromFile:aJSONFileName];
    NSDictionary *dictionary = [BSJSONParser dictFromJSON:JSONString];
    return dictionary;
}

+ (NSString *)JSONStringFromFile:(NSString *)aJSONFileName {
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]]
                          pathForResource:aJSONFileName ofType:@"json"];

    NSString *JSONFromFile = [NSString stringWithContentsOfFile:filePath
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
    return JSONFromFile;
}

@end
