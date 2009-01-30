#import "SUPreferencesWindowController.h"

@interface SUPreferencesWindowController (Private)

- (NSView *) activeView;

@end

@implementation SUPreferencesWindowController

@synthesize sparkleUpdater;

/*
 Connects the Sparkle Updater shared instance to the local property.
 */

- (void) awakeFromNib {
	self.sparkleUpdater = [SUUpdater sharedUpdater];
}

/*
 Adds all the preference panes.
 */

- (void) setupToolbar {
	[self addView:automaticUpdatesView label:@"Automatic Updates"];
	
	NSImage *image = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"Upload" ofType:@"png"]];
	[self addView:uploadingView label:@"Uploading" image:image];
	[image release];
	
	[self addView:metadataView label:@"Metadata" image:[NSImage imageNamed:@"NSInfo"]];
}

- (IBAction) checkForUpdates:(id)sender {
	[sparkleUpdater checkForUpdates:sender];
}

- (IBAction) showHelp:(id)sender {
	NSString *anchor;
	if ([[self activeView] isEqualTo:automaticUpdatesView]) anchor = @"automatic_updates";
	if ([[self activeView] isEqualTo:uploadingView]) anchor = @"uploading_preferences";
	if ([[self activeView] isEqualTo:metadataView]) anchor = @"metadata_preferences";
	[[NSHelpManager sharedHelpManager] openHelpAnchor:anchor inBook:@"Scribd Uploader Help"];
}

@end

@implementation SUPreferencesWindowController (Private)

- (NSView *) activeView {
	return [[self window] initialFirstResponder];
}

@end
