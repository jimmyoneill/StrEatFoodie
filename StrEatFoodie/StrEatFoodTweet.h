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

@property (nonatomic, readonly) NSNumber *mealType;
@property (nonatomic, readonly) NSInteger hour;
@property (nonatomic, readonly) NSString *formattedDate;

@end
