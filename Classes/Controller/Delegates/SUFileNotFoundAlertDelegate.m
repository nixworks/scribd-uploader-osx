#import "SUFileNotFoundAlertDelegate.h"

@interface SUFileNotFoundAlertDelegate (Private)

#pragma mark Alert

/*
 Builds and displays the file not found alert.
 */

- (void) showAlert:(NSDictionary *)params;

@end

#pragma mark -

@implementation SUFileNotFoundAlertDelegate

#pragma mark Showing the alert

- (void) showAlertFor:(NSUInteger)deletedFiles singleFileName:(NSString *)filename {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithUnsignedInteger:deletedFiles], @"fileCount",
							filename, @"singleFileName",
							NULL];
	
	if ([window isVisible]) [self showAlert:params];
	else [window addObserver:self forKeyPath:@"visible" options:NSKeyValueObservingOptionNew context:[params retain]];
	//TODO potential race condition if the window is made visible during the addObserver call
}

#pragma mark KVO

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"visible"]) {
		[window removeObserver:self forKeyPath:@"visible"];
		[self showAlert:(NSDictionary *)context];
		[(NSDictionary *)context release];
	}
	else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


#pragma mark Delegate responders

/*
 Handles the dismissal of the alert by releasing the object.
 */

- (void) filesNotFoundAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	[alert release];
};

@end

@implementation SUFileNotFoundAlertDelegate (Private)

#pragma mark Alert

- (void) showAlert:(NSDictionary *)params {
	NSUInteger deletedFiles = [[params objectForKey:@"fileCount"] unsignedIntegerValue];
	NSString *filename = [params objectForKey:@"singleFileName"];
	
	// build the alert
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert addButtonWithTitle:@"OK"];
	if (deletedFiles == 1) {
		NSString *message = [[NSString alloc] initWithFormat:@"The file “%@” could not be found.", filename];
		[alert setMessageText:message];
		[message release];
		[alert setInformativeText:@"It has been removed from the list."];
	}
	else {
		NSString *message = [[NSString alloc] initWithFormat:@"%d files could not be found.", deletedFiles];
		[alert setMessageText:message];
		[message release];
		[alert setInformativeText:@"These files have been removed from the list."];
	}
	[alert setShowsHelp:YES];
	[alert setHelpAnchor:@"file_moved"];
	
	// display the alert
	[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(filesNotFoundAlertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

@end
