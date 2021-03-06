/*!
 @brief Delegate class that responds to changes in the Information drawer and
 its token field.
 @details This class shows or hides the Information drawer as the selection
 changes, changing the name of the "Show/Hide Information Drawer" menu item as
 appropriate. It also performs the fade effect as the selection changes between
 uploaded and pending files. Finally, it provides the content for the Tags token
 field.
 @todo When fading between tab views, tab content isn't updated until after it's
 animated.
 @ingroup delegates
 */

@interface SUInformationDrawerDelegate : NSObject {
	@private
		IBOutlet SUDocumentArrayController *documentsController;
		IBOutlet NSTokenField *tagsField;
		IBOutlet NSDrawer *drawer;
		IBOutlet NSMenuItem *toggleDrawerItem;
}

#pragma mark Actions
/** @name Actions */
//@{

/*!
 @brief Displays a relevant help topic.
 @param sender The object that sent the action (unused).
 */

- (IBAction) showHelp:(id)sender;

/*!
 @brief Toggles the visibility of the information drawer and updates the
 title of the menu item.
 @param sender The object that sent the action (unused).
 */

- (IBAction) toggleMenuItem:(id)sender;

//@}
@end
