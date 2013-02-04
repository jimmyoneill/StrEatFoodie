#import "StrEatFoodTweet.h"
#import "StrEatFoodStorage.h"
#import "NSString+Levenshtein.h"

@interface StrEatFoodTweet ()

@property (nonatomic, readonly) NSArray *mealTypeStrings;
@property (nonatomic) NSNumber *mealType;
@property (nonatomic) NSString *mealString;

@end

@implementation StrEatFoodTweet

NSNumber *_isMeal;

@synthesize mealTypeStrings = _mealTypeStrings;
@synthesize mealType = _mealType;
@synthesize formattedDate = _formattedDate;

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
    // If the tweet has at least 5 mentions and we have at least one of those on our whitelist, then
    // add the other mentions to the truck whitelist and consider this a meal tweet.
    
    if (self.userMentions.count > 4) {
        NSArray *splitMentions = [self whitelistAndNonWhitelistMentions];
        NSMutableArray *whitelistMentions = [splitMentions objectAtIndex:0];
        NSMutableArray *nonWhitelistMentions = [splitMentions objectAtIndex:1];
        
        if (whitelistMentions.count > 0) {
            NSString *mealString = [self findMealString];
            self.mealType = [self mealTypeStringToNumber:mealString];
            [[StrEatFoodStorage sharedStorage] addTrucks:nonWhitelistMentions];
            return YES;
        }
    }
    
    return NO;
}

- (NSString *)findMealString
{
    NSCharacterSet *charSet = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz"] invertedSet];
    NSArray *lowercaseChunks = [[[self text] lowercaseString] componentsSeparatedByCharactersInSet:charSet];
    
    for (NSString *word in lowercaseChunks) {
        for (NSString *mealTypeString in self.mealTypeStrings) {
            int levDistance = [word computeLevenshteinDistanceWithString:mealTypeString];
            // computeLevenshteinDistanceWithString: returns -1 in the case of an error.
            if (levDistance >= 0 && levDistance <= 2) {
                return mealTypeString;
            }
        }
    }
    
    return nil;
}

// Returns an array of two arrays - the mentions that are in the whitelist and the
// mentions that are not, respectively.
- (NSArray *)whitelistAndNonWhitelistMentions
{
    NSMutableArray *truckWhitelist = [[StrEatFoodStorage sharedStorage] trucks];
    NSMutableArray *whitelistMentions = [[NSMutableArray alloc] init];
    NSMutableArray *nonWhitelistMentions = [[NSMutableArray alloc] init];
    
    for (NSString *mention in self.mentionedScreenNames) {
        if ([truckWhitelist containsObject:mention]) {
            [whitelistMentions addObject:mention];
        } else {
            [nonWhitelistMentions addObject:mention];
        }
    }
    
    return [NSArray arrayWithObjects:whitelistMentions, nonWhitelistMentions, nil];
}

- (NSString *)mealTypeToString:(MealType)mealType
{
    return [self.mealTypeStrings objectAtIndex:mealType];
}

- (NSNumber *)mealTypeToNumber:(MealType)mealType
{
    return [NSNumber numberWithInt:mealType];
}

- (NSNumber *)mealTypeStringToNumber:(NSString *)mealTypeString
{
    if (!mealTypeString) {
        return nil;
    }
    MealType type = [self mealTypeStringToMealType:mealTypeString];
    return [self mealTypeToNumber:type];
}

- (MealType)mealTypeStringToMealType:(NSString*)mealTypeString
{
    return (MealType)[self.mealTypeStrings indexOfObjectIdenticalTo:mealTypeString];
}

- (NSDate *)date
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    [inputFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSDate *date = [inputFormatter dateFromString:[self createdAt]];
    return date;
}

- (NSInteger)hour
{
    NSDate *date = self.date;

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit) fromDate:date];
    NSInteger hour = [components hour];
    return hour;
}

- (NSString*)formattedDate
{
    if (!_formattedDate) {
        NSDate *date = self.date;
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateStyle:NSDateFormatterMediumStyle];
        [outputFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [outputFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"PST"]];
        
        _formattedDate = [outputFormatter stringFromDate:date];
    }
    
    return _formattedDate;
}

@end
