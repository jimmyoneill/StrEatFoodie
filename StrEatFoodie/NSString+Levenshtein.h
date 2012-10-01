#import <Foundation/Foundation.h>

@interface NSString (Levenshtein)

int minimum(int a,int b,int c);
- (int)computeLevenshteinDistanceWithString:(NSString *)string;

@end
