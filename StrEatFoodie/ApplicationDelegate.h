#import "DebugMacros.h"
#import "MenubarController.h"
#import "PanelController.h"
#import "StrEatFoodMealIndex.h"

@interface ApplicationDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate>

@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, strong, readonly) PanelController *panelController;
@property (nonatomic) NSMutableArray *lunchTrucks;
@property (nonatomic) StrEatFoodMealIndex *mealIndex;

- (IBAction)togglePanel:(id)sender;

@end
