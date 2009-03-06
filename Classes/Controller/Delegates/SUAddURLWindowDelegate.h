/*!
 @class SUAddURLWindowDelegate
 @abstract Handles events regarding the Add URL window.
 */

@interface SUAddURLWindowDelegate : NSObject {
	IBOutlet NSWindow *window;
	IBOutlet SUDatabaseHelper *db;
	NSString *URLString;
}

#pragma mark Properties

/*!
 @property URLString
 @abstract The text entered into the URL field.
 */

@property (retain) NSString *URLString;

#pragma mark Actions

/*!
 @method addURL:
 @abstract Adds a new document by remote URL to the queue.
 @param sender The object that sent the action.
 @discussion This method also closes the Add URL window and clears the text
 field for the next entry.
 */

- (IBAction) addURL:(id)sender;

/*!
 @method showHelp:
 @abstract Displays a contextually relevant help book page.
 @param sender The object that sent the action.
 */

- (IBAction) showHelp:(id)sender;

@end
