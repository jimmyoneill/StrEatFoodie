#import "DebugMacros.h"
#import "StrEatFoodMealIndex.h"
#import "StrEatFoodTweet.h"
#import "TweetStreamer.h"

@interface StrEatFoodMealIndex ()

@property (nonatomic, readwrite) NSArray *lunchTrucks;
@property (nonatomic, readwrite) NSArray *dinnerTrucks;

@property (nonatomic) TweetStreamer *streamer;

@end

@implementation StrEatFoodMealIndex

@synthesize lunchTrucks = _lunchTrucks;
@synthesize dinnerTrucks = _dinnerTrucks;
@synthesize lunchUpdateDate = _lunchUpdateDate;
@synthesize dinnerUpdateDate = _dinnerUpdateDate;

@synthesize streamer = _streamer;

- (id)init
{
    self = [super init];
    if (self) {
        _lunchTrucks = [[NSArray alloc] init];
        _dinnerTrucks = [[NSArray alloc] init];
        _streamer = [[TweetStreamer alloc] init];
    }
    return self;
}

- (void)indexTweets:(NSArray*)tweets
{
    NSMutableArray *mealTypesToUpdate = [[NSMutableArray alloc] initWithObjects:
                                     [NSNumber numberWithInt:Lunch],
                                     [NSNumber numberWithInt:Dinner], nil];

    for (TSTweet *tweet in [tweets reverseObjectEnumerator]) {
        
        if (!mealTypesToUpdate.count) break;
        
        DLog(@"%@", tweet.text);
        StrEatFoodTweet* strEatTweet = [[StrEatFoodTweet alloc] initWithTweet:tweet];
        
        if (strEatTweet.isMeal) {
            NSNumber *mealType = [NSNumber numberWithInt:strEatTweet.mealType];
            
            if ([mealTypesToUpdate containsObject:mealType]) {
                [self setTrucks:[strEatTweet mentionedScreenNames] forMealType:[mealType intValue] date:[strEatTweet formattedDate]];
                [mealTypesToUpdate removeObject:mealType];
            }
        }
    }
}

- (void)setTrucks:(NSArray*)trucks forMealType:(MealType)meal date:(NSString*)date
{
    NSArray *users = [self.streamer getInformationForUserNames:trucks];
    if (!(users && users.count)) return;
    
    if (meal == Lunch) {
        self.lunchTrucks = users;
        self.lunchUpdateDate = date;
    } else if (meal == Dinner) {
        self.dinnerTrucks = users;
        self.dinnerUpdateDate = date;
    } 
}
@end
