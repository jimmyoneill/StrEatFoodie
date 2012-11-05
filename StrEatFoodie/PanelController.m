#import "ApplicationDelegate.h"
#import "PanelController.h"
#import "BackgroundView.h"
#import "StatusItemView.h"
#import "MenubarController.h"
#import "TPUser.h"

#define OPEN_DURATION .15
#define CLOSE_DURATION .1
#define SEARCH_INSET 17
#define MENU_ANIMATION_DURATION .1

#pragma mark -

@interface PanelController ()

@property (nonatomic) NSArray *lunchTrucks;
@property (nonatomic) NSArray *dinnerTrucks;
@property (nonatomic, readwrite) NSString *lunchUpdateDate;
@property (nonatomic, readwrite) NSString *dinnerUpdateDate;

@property (nonatomic) NSMutableArray *mealTrucks;
@property (nonatomic) NSMutableArray *mealDates;

@property (nonatomic, weak) NSArray *selectedTrucks;
@property (nonatomic, weak) NSString *selectedDate;

@end

@implementation PanelController

@synthesize backgroundView = _backgroundView;
@synthesize delegate = _delegate;
@synthesize searchField = _searchField;
@synthesize textField = _textField;
@synthesize tableView = _tableView;
@synthesize dateLabel = _dateLabel;
@synthesize mealControl = _mealControl;
@synthesize spinner = _spinner;

@synthesize lunchTrucks = _lunchTrucks;
@synthesize dinnerTrucks = _dinnerTrucks;
@synthesize lunchUpdateDate = _lunchUpdateDate;
@synthesize dinnerUpdateDate = _dinnerUpdateDate;

@synthesize mealTrucks = _mealTrucks;
@synthesize mealDates = _mealDates;

NSString* dateString;

- (void)updateTrucks
{
    ApplicationDelegate *appDel = (ApplicationDelegate*)[[NSApplication sharedApplication] delegate];
    self.lunchTrucks = appDel.mealIndex.lunchTrucks;
    self.dinnerTrucks = appDel.mealIndex.dinnerTrucks;
    
    self.lunchUpdateDate = appDel.mealIndex.lunchUpdateDate;
    self.dinnerUpdateDate = appDel.mealIndex.dinnerUpdateDate;
    
    self.mealTrucks = [NSArray arrayWithObjects:self.lunchTrucks, self.dinnerTrucks, nil];
    self.mealDates = [NSArray arrayWithObjects:self.lunchUpdateDate, self.dinnerUpdateDate, nil];
    
    self.selectedTrucks = [self getSelectedMealTrucks];
    self.selectedDate = [self getSelectedDate];
    
    [self reloadTableView];
}

- (void)reloadTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.mealTrucks) {
            [self.spinner stopAnimation:self];
            [self.spinner setHidden:YES];
        }
        
        if (self.selectedDate) {
            if ([self.selectedDate isEqualToString:@""]) {
                [self.dateLabel setStringValue:[NSString stringWithFormat:@"Not yet updated"]];
            } else {
                [self.dateLabel setStringValue:[NSString stringWithFormat:@"Last updated %@", self.selectedDate]];
            }
        }
        
        [self.tableView reloadData];
    });
}

- (IBAction)performActionForClick:(id)sender
{
    self.selectedTrucks = [self getSelectedMealTrucks];
    self.selectedDate = [self getSelectedDate];
    [self reloadTableView];
}

- (NSArray*)getSelectedMealTrucks
{
    return self.mealTrucks ? [self.mealTrucks objectAtIndex:[self.mealControl selectedSegment]] : nil;
}

- (NSString*)getSelectedDate
{
    return self.mealDates ? [self.mealDates objectAtIndex:[self.mealControl selectedSegment]] : nil;
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSArray *trucks = self.selectedTrucks;

    return trucks ? [trucks count] : 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSArray *trucks = self.selectedTrucks;

    return trucks ? [trucks objectAtIndex:rowIndex] : nil;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSArray *trucks = self.selectedTrucks;
    
    NSTableCellView *cellView = (NSTableCellView*)cell;
    TPUser *t = [trucks objectAtIndex:row];
    [cellView.textField setStringValue:t.name];
}

#pragma mark - TableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSArray *trucks = self.selectedTrucks;

    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"truckview" owner:self];
    
    TPUser *t = [trucks objectAtIndex:row];
    
    [cellView.textField setStringValue:t.name];
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:t.profileImageURL];
    
    [cellView.imageView setWantsLayer:YES];
    cellView.imageView.layer.masksToBounds = YES;
    cellView.imageView.layer.borderWidth = 1.0;
    cellView.imageView.layer.borderColor = CGColorCreateGenericGray(1, 1);
    cellView.imageView.layer.cornerRadius = 8.0;
    [cellView.imageView setImageScaling:NSScaleToFit];
    [cellView.imageView setImage:image];
    
    return cellView;
}

- (void)doubleClickInTableView
{
    NSArray *trucks = self.selectedTrucks;

    TPUser *t = [trucks objectAtIndex:self.tableView.clickedRow];
    NSURL *url = t.URL;
    if (url == nil) {
        url = t.twitterURL;    
    }
    
    if (url != nil) {
        [[NSWorkspace sharedWorkspace] openURL:url];
    } else {
        DLog(@"Attempted to open an invalid url");
    }
}

/*
 - (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
 {
    
     NSTableCellView *cellView = (NSTableCellView*)cell;
     FoodTruck *t = [lunchTrucks objectAtIndex:row];
     [cellView.textField setStringValue:t.name];
      
 }
*/

#pragma mark -

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate
{
    self = [super initWithWindowNibName:@"Panel"];
    if (self != nil)
    {
        _delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidChangeNotification object:self.searchField];
}

#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.spinner startAnimation:self];
    
    // Make a fully skinned panel
    NSPanel *panel = (id)[self window];
    [panel setAcceptsMouseMovedEvents:YES];
    [panel setLevel:NSPopUpMenuWindowLevel];
    [panel setOpaque:NO];
    [panel setBackgroundColor:[NSColor clearColor]];
    
    [self reloadTableView];
    //self.selectedTrucks = [self getSelectedMealTrucks];
    //self.selectedDate = [self getSelectedDate];
    [self.tableView setDoubleAction:@selector(doubleClickInTableView)];
    //[self reloadTableView];
    //[_dateLabel setStringValue:dateString];
}

#pragma mark - Public accessors

- (BOOL)hasActivePanel
{
    return _hasActivePanel;
}

- (void)setHasActivePanel:(BOOL)flag
{
    if (_hasActivePanel != flag)
    {
        _hasActivePanel = flag;
        
        if (_hasActivePanel)
        {
            [self openPanel];
        }
        else
        {
            [self closePanel];
        }
    }
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    self.hasActivePanel = NO;
}

- (void)windowDidResignKey:(NSNotification *)notification;
{
    if ([[self window] isVisible])
    {
        self.hasActivePanel = NO;
    }
}

- (void)windowDidResize:(NSNotification *)notification
{
    NSWindow *panel = [self window];
    NSRect statusRect = [self statusRectForWindow:panel];
    NSRect panelRect = [panel frame];
    
    CGFloat statusX = roundf(NSMidX(statusRect));
    CGFloat panelX = statusX - NSMinX(panelRect);
    
    self.backgroundView.arrowX = panelX;     
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender
{
    self.hasActivePanel = NO;
}

#pragma mark - Public methods

- (NSRect)statusRectForWindow:(NSWindow *)window
{
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = NSZeroRect;
    
    StatusItemView *statusItemView = nil;
    if ([self.delegate respondsToSelector:@selector(statusItemViewForPanelController:)])
    {
        statusItemView = [self.delegate statusItemViewForPanelController:self];
    }
    
    if (statusItemView)
    {
        statusRect = statusItemView.globalRect;
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    }
    else
    {
        statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
        statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
    }
    return statusRect;
}

- (void)openPanel
{
    NSWindow *panel = [self window];
    
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = [self statusRectForWindow:panel];
    
    NSRect panelRect = [panel frame];
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
    
    [NSApp activateIgnoringOtherApps:NO];
    [panel setAlphaValue:0];
    [panel setFrame:statusRect display:YES];
    [panel makeKeyAndOrderFront:nil];
    
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    if ([currentEvent type] == NSLeftMouseDown)
    {
        NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
        BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
        BOOL shiftOptionPressed = (clearFlags == (NSShiftKeyMask | NSAlternateKeyMask));
        if (shiftPressed || shiftOptionPressed)
        {
            openDuration *= 10;
            
            if (shiftOptionPressed)
                NSLog(@"Icon is at %@\n\tMenu is on screen %@\n\tWill be animated to %@",
                      NSStringFromRect(statusRect), NSStringFromRect(screenRect), NSStringFromRect(panelRect));
        }
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[panel animator] setFrame:panelRect display:YES];
    [[panel animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
    
    [panel performSelector:@selector(makeFirstResponder:) withObject:self.searchField afterDelay:openDuration];
}

- (void)closePanel
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        
        [self.window orderOut:nil];
    });
}

@end

