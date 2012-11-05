#import <Foundation/Foundation.h>
#import "TPTweet.h"

typedef enum {
    Lunch = 0,
    Dinner = 1,
} MealType;

#define MEAL_TYPE_STRINGS @"lunch", @"dinner", nil

@interface StrEatFoodTweet : TPTweet

- (id)initWithTweet:(TPTweet*)tweet;
- (BOOL)isMeal;
- (NSString*)formattedDate;

@property (nonatomic) MealType mealType;

@end
