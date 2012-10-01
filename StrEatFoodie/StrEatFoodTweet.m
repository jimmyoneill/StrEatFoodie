#import "StrEatFoodTweet.h"
#import "NSString+Levenshtein.h"

@interface StrEatFoodTweet () 

@property (nonatomic, readonly) NSArray *mealTypeStrings;

@end

@implementation StrEatFoodTweet

NSNumber *_isMeal;

@synthesize mealTypeStrings = _mealTypeStrings;
@synthesize mealType = _mealType;

- (id)initWithTweet:(TSTweet*)tweet
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
    for (NSString *word in [[[self text] lowercaseString] componentsSeparatedByString:@" "]) {
        for (NSString *mealTypeString in self.mealTypeStrings) {
            if ([word computeLevenshteinDistanceWithString:mealTypeString] <= 2) {
                self.mealType = [self mealTypeStringToEnum:mealTypeString];
                return true;
            }
        }
    }
    return false;
}

- (NSString*)mealTypeToString:(MealType)mealType
{
    return [self.mealTypeStrings objectAtIndex:mealType];
}

- (MealType)mealTypeStringToEnum:(NSString*)mealTypeString
{
    return (MealType)[self.mealTypeStrings indexOfObject:mealTypeString];
}

/*
- (NSArray*)foodTrucks
{
    NSMutableArray *trucks = [[NSMutableArray alloc] init];
    for (NSString *screenName in [self mentionedScreenNames]) {
        [trucks addObject:[[FoodTruck alloc] initWithTwitterHandle:screenName]];
    }
    return trucks;
}
 */

- (NSString*)formattedDate
{
    return [[[[self createdAt] componentsSeparatedByString:@" "] subarrayWithRange:NSMakeRange(0, 3)] componentsJoinedByString:@" "];
}

@end
