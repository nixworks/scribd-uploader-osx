/*!
 @class SUIndexPathValueTransformer
 @abstract Converts between @link SUCategory SUCategory @/link objects and their
 index paths.
 @discussion Because this value transformer is meant to work with selections, it
 actually converts between arrays of each object.
 
 This object must be initialized with a managed object context to search for
 categories in.
 */

@interface SUIndexPathValueTransformer : NSValueTransformer {
	@private
		NSManagedObjectContext *managedObjectContext;
}

#pragma mark Properties

/*!
 @property managedObjectContext
 @abstract The managed object context to search for categories in.
 */

@property (retain) NSManagedObjectContext *managedObjectContext;

@end