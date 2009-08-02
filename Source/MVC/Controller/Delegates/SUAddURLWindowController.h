/*!
 @class SUAddURLWindowDelegate
 @abstract This class manages the state of and responds to events from the Add
 URL window.
 */

@interface SUAddURLWindowController : NSObject {
	@private
		IBOutlet NSWindow *window;
		IBOutlet SUDatabaseHelper *db;
		IBOutlet SUImagePreviewView *preview;
		NSString *URLString;
		BOOL downloading;
		NSMutableData *previewImageData;
}

#pragma mark Properties

/*!
 @property URLString
 @abstract The text entered into the URL field.
 */

@property (retain) NSString *URLString;

/*!
 @property downloading
 @abstract YES if an image preview is in the process of being downloaded; NO if
 no downloading is occurring.
 */

@property (assign) BOOL downloading;

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
