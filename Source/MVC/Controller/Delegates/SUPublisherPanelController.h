/*!
 @class SUPublisherPanelDelegate
 @abstract Delegate for the Publisher Information panel that responds to events
 from the panel and initializes its value transformer.
 */

@interface SUPublisherPanelController : NSObject {
	@private
		IBOutlet NSPanel *panel;
		IBOutlet NSMenuItem *togglePanelItem;
		IBOutlet NSArrayController *documents;
}

/*!
 @method showHelp:
 @abstract Opens a help page regarding the publisher panel.
 @param sender The object that initiated the action.
 */

- (IBAction) showHelp:(id)sender;

/*!
 @method toggleMenuItem:
 @abstract Shows or hides the publisher panel and updates the "Show/Hide
 Publisher Panel" menu item to reflect the change.
 @param sender The object that initiated the action.
 */

- (IBAction) toggleMenuItem:(id)sender;

/*!
 @method setToday:
 @abstract Sets the date published of all selected documents to the current
 date.
 @param sender The object that initiated the action.
 */

- (IBAction) setToday:(id)sender;

@end