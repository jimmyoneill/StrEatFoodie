#import "StrEatFoodTweet.h"
#import "NSString+Levenshtein.h"

@interface StrEatFoodTweet () 

@property (nonatomic, readonly) NSArray *mealTypeStrings;

@end

@implementation StrEatFoodTweet

NSNumber *_isMeal;

@synthesize mealTypeStrings = _mealTypeStrings;
@synthesize mealType = _mealType;

- (id)initWithTweet:(TPTweet*)tweet
{
    self = [super initWithJsonDict:tweet.jsonDict];
    if (self) {
        _mealTypeStrings = [[NSArray alloc] initWithObjects:MEAL_TYPE_STRINGS];
        _isMeal = nil;
    }
    return self;
}

- (BOOL)isMeal
{
    if (!_isMeal) {
        _isMeal = [NSNumber numberWithBool:[self checkForMeal]];
    }
    return [_isMeal boolValue];
}

- (BOOL)checkForMeal
{
    // If the tweet mentions at least 4 users and has either the word "lunch" or "dinner" within an
    // edit distance of 2, then we consider it to be a lunch or dinner tweet, respectively.
    // Pretty naive, I know, but 98% of the time it works every time.

    if ([[self userMentions] count] > 3) {
        NSArray *lowercaseChunks = [[[self text] lowercaseString] componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz"] invertedSet]];
        
        for (NSString *word in lowercaseChunks) {
            for (NSString *mealTypeString in self.mealTypeStrings) {
                int levDistance = [word computeLevenshteinDistanceWithString:mealTypeString];
                // computeLevenshteinDistanceWithString: returns -1 in the case of an error.
                if (levDistance >= 0 && levDistance <= 2) {
                    self.mealType = [self mealTypeStringToEnum:mealTypeString];
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (NSString*)mealTypeToString:(MealType)mealType
{
    return [self.mealTypeStrings objectAtIndex:mealType];
}

- (MealType)mealTypeStringToEnum:(NSString*)mealTypeString
{
    return (MealType)[self.mealTypeStrings indexOfObjectIdenticalTo:mealTypeString];
}

- (NSString*)formattedDate
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    [inputFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];

    NSDate *date = [inputFormatter dateFromString:[self createdAt]];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateStyle:NSDateFormatterMediumStyle];
    [outputFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [outputFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    return [outputFormatter stringFromDate:date];
}

@end
