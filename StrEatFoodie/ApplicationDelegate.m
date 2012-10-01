#import "ApplicationDelegate.h"
#import "TweetStreamer.h"
#import "TSTweet.h"
#import "StrEatFoodTweet.h"

@implementation ApplicationDelegate

@synthesize panelController = _panelController;
@synthesize menubarController = _menubarController;
@synthesize lunchTrucks;
@synthesize mealIndex = _mealIndex;

#pragma mark -

- (void)dealloc
{
    [_panelController removeObserver:self forKeyPath:@"hasActivePanel"];
}

#pragma mark -

void *kContextActivePanel = &kContextActivePanel;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kContextActivePanel) {
        self.menubarController.hasActiveIcon = self.panelController.hasActivePanel;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - NSApplicationDelegate

/*
- (void)requestFailedWithError:(NSError*)error
{
    
}

- (void)requestSucceededWithParsedJSON:(NSArray*)dictArray
{
    for (NSDictionary *tweetDict in dictArray) {
        if (![self textForTweet:tweetDict]) {
            DLog(@"There's no text field in the JSON response, probably because of rate limiting");
        } else if ([self tweetIsLunch:tweetDict]) {
            if ([self lunchTweetIsNew:tweetDict]) {
                [self updateLunch:tweetDict];
                break;
            }
        }
    }
}
*/


NSDictionary *currentLunchTweet;

- (void)updateLunch:(NSDictionary*)tweetDict
{
    /*
    NSLog(@"updateLunch");
    currentLunchTweet = tweetDict;
    lunchTrucks = [truckIndex trucksForMentions:[self mentionsForTweet:tweetDict]];
    [self.panelController setDateString:[self dateForTweetDict:tweetDict]];
    [self.panelController setLunchTrucks:lunchTrucks];
     */
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    self.lunchTrucks = [[NSMutableArray alloc] init];
    self.mealIndex = [[StrEatFoodMealIndex alloc] init];
    
    // Install icon into the menu bar
    self.menubarController = [[MenubarController alloc] init];
    
    TweetStreamer *streamer = [[TweetStreamer alloc] init];
    [streamer beginStreamForUserName:@"SoMaStrEatFood"
                   withReceivedBlock:^(NSArray *tweets) {
                       dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                       dispatch_async(queue, ^{
                           [self.mealIndex indexTweets:tweets];
                           dispatch_sync(dispatch_get_main_queue(), ^{
                               [self.panelController updateTrucks];
                           });
                       });
                   }];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{    
    // Explicitly remove the icon from the menu bar
    self.menubarController = nil;
    return NSTerminateNow;
}

#pragma mark - Actions

- (IBAction)togglePanel:(id)sender
{
    self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
    self.panelController.hasActivePanel = self.menubarController.hasActiveIcon;
}

#pragma mark - Public accessors

- (PanelController *)panelController
{
    if (_panelController == nil) {
        _panelController = [[PanelController alloc] initWithDelegate:self];
        [_panelController addObserver:self forKeyPath:@"hasActivePanel" options:0 context:kContextActivePanel];
    }
    return _panelController;
}

#pragma mark - PanelControllerDelegate

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller
{
    return self.menubarController.statusItemView;
}

@end
