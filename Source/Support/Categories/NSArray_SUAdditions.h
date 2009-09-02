/*!
 @category NSArray(SUAdditions)
 @abstract Utility additions to the
 @link //apple_ref/occ/cl/NSArray NSArray @/link class.
 */

@interface NSArray (SUAdditions)

#pragma mark Initializing an Array

/*!
 @method initWithObject:
 @abstract Initializes an array containing a single object.
 @param object The object to place in the new array.
 @result The initialized array.
 */

- (NSArray *) initWithObject:(id)object;

#pragma mark Deriving New Arrays

/*!
 @method reversedArray
 @abstract Returns an array whose elements are in the reverse order of this
 array.
 @result A copy of this array with its elements reversed.
 */

- (NSArray *) reversedArray;

/*!
 @method map:
 @abstract Returns a new array created by applying block to each element in this
 array.
 @param block The operation to perform on each element.
 @result A new array resulting from the map operation.
 */

- (NSArray *) map:(id (^)(id value))block;

@end
