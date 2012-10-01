#import <Foundation/Foundation.h>
#import "TSTweet.h"

typedef enum {
    Lunch,
    Dinner,
} MealType;

#define MEAL_TYPE_STRINGS @"lunch", @"dinner", nil

@interface StrEatFoodTweet : TSTweet

- (id)initWithTweet:(TSTweet*)tweet;
- (BOOL)isMeal;
- (NSArray*)foodTrucks;
- (NSString*)formattedDate;

@property (nonatomic) MealType mealType;

@end
