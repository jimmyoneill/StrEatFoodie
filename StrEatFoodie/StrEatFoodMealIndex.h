#import <Foundation/Foundation.h>

@interface StrEatFoodMealIndex : NSObject

- (void)indexTweets:(NSArray*)tweets;

@property (nonatomic, readonly) NSArray *lunchTrucks;
@property (nonatomic, readonly) NSArray *dinnerTrucks;
@property (nonatomic, readwrite) NSString *lunchUpdateDate;
@property (nonatomic, readwrite) NSString *dinnerUpdateDate;

@end
