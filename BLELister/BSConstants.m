//
//  BSConstants.m
//  BLELister
//
//  Created by Steve Baker on 11/14/13.
//  Copyright 2013 Beepscore LLC. All rights reserved.
//

#import "BSConstants.h"
#import "DDLog.h"

// In .xcodeproj Preprocessor macros for Debug build, set DEBUG=1
// Log levels: off, error, warn, info, verbose
#ifdef DEBUG
int const ddLogLevel = LOG_LEVEL_VERBOSE;
#else
int const ddLogLevel = LOG_LEVEL_OFF;
#endif
