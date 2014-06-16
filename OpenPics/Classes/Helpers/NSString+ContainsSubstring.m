//
//  NSString+ContainsSubString.m
//
//  Created by David Ohayon on 7/23/13.
//

#import "NSString+ContainsSubstring.h"

@implementation NSString (ContainsSubstring)

- (BOOL) containsSubstring:(NSString*)substring {
    if ([self rangeOfString:substring].location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL) containsSubstring:(NSString *)substring caseSensitive:(BOOL)caseSensitive {
    if (caseSensitive) {
        return [self containsSubstring:substring];
    }
    if ([self rangeOfString:substring options:NSCaseInsensitiveSearch].location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

@end
