#import "BackgroundView.h"
#import "StatusItemView.h"

@class PanelController;

@protocol PanelControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller;

@end

#pragma mark -

@interface PanelController : NSWindowController <NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate>
{
    BOOL _hasActivePanel;
    __unsafe_unretained BackgroundView *_backgroundView;
    __unsafe_unretained id<PanelControllerDelegate> _delegate;
    __unsafe_unretained NSSearchField *_searchField;
    __unsafe_unretained NSTextField *_textField;
    __unsafe_unretained NSTableView *_tableView;
    __unsafe_unretained NSTextField *_dateLabel;
    __unsafe_unretained NSSegmentedControl *_mealControl;
    __unsafe_unretained NSScrollView *_scrollView;
    __weak NSProgressIndicator *_spinner;
}

@property (nonatomic, unsafe_unretained) IBOutlet BackgroundView *backgroundView;
@property (nonatomic, unsafe_unretained) IBOutlet NSSearchField *searchField;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextField *textField;
@property (nonatomic, unsafe_unretained) IBOutlet NSTableView *tableView;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextField *dateLabel;
@property (nonatomic, unsafe_unretained) IBOutlet NSSegmentedControl *mealControl;
@property (nonatomic, unsafe_unretained) IBOutlet NSScrollView *scrollView;

@property (weak) IBOutlet NSProgressIndicator *spinner;

- (IBAction)performActionForClick:(id)sender;
- (IBAction)quitClicked:(id)sender;

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, unsafe_unretained, readonly) id<PanelControllerDelegate> delegate;

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate;

- (void)openPanel;
- (void)closePanel;
- (NSRect)statusRectForWindow:(NSWindow *)window;

- (void)updateTrucks;

@end
