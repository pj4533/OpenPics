//
//  NSString+ContainsSubString.h
//
//  Created by David Ohayon on 7/23/13.
//

#import <Foundation/Foundation.h>

@interface NSString (ContainsSubstring)
- (BOOL) containsSubstring:(NSString*)substring;
- (BOOL) containsSubstring:(NSString *)substring caseSensitive:(BOOL)caseSensitive;
@end
