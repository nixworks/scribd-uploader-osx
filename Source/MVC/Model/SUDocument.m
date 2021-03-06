#import "SUDocument.h"

static NSDictionary *kinds = NULL, *quickLookOptions = NULL;
static NSOperationQueue *downloadIconQueue = NULL;

@interface SUDocument (Private)

#pragma mark Helpers

/*
 Returns a list of supported filetypes mapped to descriptions of each type.
 */

+ (NSDictionary *) kinds;

#pragma mark Setters

/*
 Private setter used for when the icon image is generated in another thread.
 */

- (void) setIcon:(NSImage *)icon;

@end

#pragma mark -

@implementation SUDocument

#pragma mark Properties

@dynamic path;
@dynamic progress;
@dynamic success;
@dynamic error;
@dynamic errorIsUnrecoverable;
@dynamic scribdID;
@dynamic hidden;
@dynamic title;
@dynamic summary;
@dynamic tags;
@dynamic author;
@dynamic publisher;
@dynamic edition;
@dynamic datePublished;
@dynamic license;
@dynamic converting;
@dynamic conversionComplete;
@dynamic assigningProperties;
@dynamic startTime;

@dynamic category;

@dynamic URL;
@dynamic fileSystemPath;
@dynamic filename;
@dynamic icon;
@dynamic kind;
@dynamic discoverability;
@dynamic errorLevel;
@dynamic scribdURL;
@dynamic editURL;
@dynamic uploaded;
@dynamic postProcessing;
@dynamic bytesUploaded;
@dynamic totalBytes;
@dynamic estimatedSecondsRemaining;
@dynamic uploading;
@dynamic pending;

#pragma mark Initializing and deallocating

/*
 You're not really supposed to override init for managed objects, but I see no
 other way I can ensure that variables are nilled out before anyone else touches
 them.
 */

- (id) init {
	if (self = [super init]) {
		kind = NULL;
		URL = NULL;
		size = NULL;
		icon = NULL;
	}
	return self;
}

/*
 Observe the path attribute so that we can prepare dependent attributes if it
 changes.
 */

- (void) awakeFromInsert {
	[self addObserver:self forKeyPath:@"path" options:NSKeyValueObservingOptionNew context:NULL];
}

/*
 Observe the path attribute so that we can prepare dependent attributes if it
 changes.
 */

- (void) awakeFromFetch {
	[self addObserver:self forKeyPath:@"path" options:NSKeyValueObservingOptionNew context:NULL];
}

/*
 Releases retained objects.
 */

- (void) dealloc {
	if (kind) [kind release];
	if (URL) [URL release];
	if (icon) [icon release];
	[super dealloc];
}

#pragma mark Dynamic properties

- (NSURL *) URL {
	if (!URL) URL = [[NSURL alloc] initWithString:self.path];
	return URL;
}

- (NSString *) fileSystemPath {
	return [self.URL relativePath];
}

- (NSString *) filename {
	if ([self remoteFile]) return [[self.URL relativeString] lastPathComponent];
	else return [[NSFileManager defaultManager] displayNameAtPath:self.fileSystemPath];
}

- (NSString *) kind {
	if (!kind) {
		if ([self remoteFile]) kind = [[[SUDocument kinds] objectForKey:[[self.URL relativeString] pathExtension]] retain];
		else kind = [[[SUDocument kinds] objectForKey:[self.fileSystemPath pathExtension]] retain];
		if (!kind) kind = @"document";
	}
	return kind;
}

- (NSImage *) icon {
	if (!icon) {
		if ([self remoteFile]) icon = [[NSWorkspace sharedWorkspace] iconForFileType:[self.filename pathExtension]];
		else icon = [[NSWorkspace sharedWorkspace] iconForFile:self.fileSystemPath];
		[icon retain];
		[icon setSize:NSMakeSize(SUPreviewIconSize, SUPreviewIconSize)];
		
		if (![self remoteFile]) {
			if (!downloadIconQueue) {
				downloadIconQueue = [[NSOperationQueue alloc] init];
				[downloadIconQueue setMaxConcurrentOperationCount:2];
				quickLookOptions = [[NSDictionary alloc] initWithObjectsAndKeys:
									(id)kCFBooleanTrue, (id)kQLThumbnailOptionIconModeKey,
									NULL];
			}
			
			[downloadIconQueue addOperationWithBlock:^{
				CGImageRef quickLookIcon = QLThumbnailImageCreate(NULL, (CFURLRef)self.URL, CGSizeMake(SUPreviewIconSize, SUPreviewIconSize), (CFDictionaryRef)quickLookOptions);
				if (quickLookIcon) {
					NSImage *betterIcon = [[NSImage alloc] initWithCGImage:quickLookIcon size:NSMakeSize(SUPreviewIconSize, SUPreviewIconSize)];
					[self performSelectorOnMainThread:@selector(setIcon:) withObject:betterIcon waitUntilDone:NO];
					[betterIcon release];
					CFRelease(quickLookIcon);
				}
			}];			
		}
	}
	
	return icon;
}

- (NSNumber *) discoverability {
	if ([self.hidden boolValue]) return [NSNumber numberWithUnsignedInteger:0];
	NSUInteger disc = 1;
	if ([[NSSpellChecker sharedSpellChecker] countWordsInString:self.summary language:NULL] >= 5) disc++;
	if ([[NSSpellChecker sharedSpellChecker] countWordsInString:self.title language:NULL] >= 2) disc++;
	if (self.category) disc++;
	return [NSNumber numberWithUnsignedInteger:disc];
}

- (BOOL) pointsToActualFile {
	if ([self remoteFile]) return NO;
	return [[NSFileManager defaultManager] fileExistsAtPath:self.fileSystemPath];
}

- (BOOL) remoteFile {
	return ![self.URL isFileURL];
}

- (NSString *) errorLevel {
	if (self.success && [self.success boolValue]) return @"Success";
	if (self.error) {
		if (self.errorIsUnrecoverable && [self.errorIsUnrecoverable boolValue]) return @"Error";
		else return @"Caution";
	}
	return @"Pending";
}

- (BOOL) uploaded {
	return (self.scribdID != NULL);
}

- (BOOL) postProcessing {
	return (self.uploaded && ([self.converting boolValue] || [self.assigningProperties boolValue]));
}

- (NSURL *) scribdURL {
	if (!self.uploaded) return NULL;
	NSString *URLString = [[NSString alloc] initWithFormat:[[[NSBundle mainBundle] infoDictionary] objectForKey:SUDocumentURLInfoKey], self.scribdID];
	NSURL *viewURL = [[NSURL alloc] initWithString:URLString];
	[URLString release];
	return [viewURL autorelease];
}

- (NSURL *) editURL {
	if (!self.uploaded) return NULL;
	NSString *URLString = [[NSString alloc] initWithFormat:[[[NSBundle mainBundle] infoDictionary] objectForKey:SUDocumentEditURLInfoKey], self.scribdID];
	NSURL *editURL = [[NSURL alloc] initWithString:URLString];
	[URLString release];
	return [editURL autorelease];
}

- (NSNumber *) bytesUploaded {
	if ([self hasSize])
		return [NSNumber numberWithUnsignedLongLong:([self.totalBytes doubleValue]*[self.progress doubleValue])];
	else return NULL;
}

- (NSNumber *) totalBytes {
	if (!size) {
		if (![self remoteFile]) {
			NSError *error = NULL;
			NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:self.fileSystemPath error:&error];
			if (!error) size = [attrs objectForKey:NSFileSize];
			if (!size) size = [NSNumber numberWithUnsignedLongLong:0];
		}
		else size = [NSNumber numberWithUnsignedLongLong:0];
		[size retain];
	}
	return size;
}

- (BOOL) hasSize {
	return (self.totalBytes && [self.totalBytes unsignedLongLongValue] > 0L);
}

- (NSNumber *) estimatedSecondsRemaining {
	if ([self.progress doubleValue] >= 1) return 0;
	if ([self hasSize] && self.uploading) {
		NSTimeInterval secondsSoFar = -[self.startTime timeIntervalSinceNow];
		if (secondsSoFar <= 2.0) return NULL; // give the estimate a few seconds to settle down
		double progressPerSecond = [self.progress doubleValue]/secondsSoFar;
		double totalTimeOfUpload = 1.0/progressPerSecond;
		return [NSNumber numberWithUnsignedLongLong:(unsigned long long)totalTimeOfUpload];
	}
	else return NULL;
}

- (BOOL) uploading {
	return (!self.uploaded && self.startTime != NULL);
}

- (BOOL) pending {
	return (self.startTime == NULL);
}

#pragma mark Configuration information

+ (NSArray *) scribdFileTypes {
	return [[self kinds] allKeys];
}

@end

#pragma mark -

@implementation SUDocument (Private)

#pragma mark Helpers

+ (NSDictionary *) kinds {
	if (!kinds) kinds = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FileTypes" ofType:@"plist"]];
	return kinds;
}

#pragma mark Setters

- (void) setIcon:(NSImage *)newIcon {
	NSImage *oldIcon = self.icon;
	icon = [newIcon retain];
	[oldIcon release];
}

@end
