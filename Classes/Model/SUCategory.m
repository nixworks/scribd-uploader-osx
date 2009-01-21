#import "SUCategory.h"

@implementation SUCategory

@dynamic name;
@dynamic position;
@dynamic scribdID;

@dynamic parent;
@dynamic children;

@dynamic indexPath;

/*
 Initialize indexPath field.
 */

- (void) awakeFromFetch {
	[super awakeFromFetch];
	indexPath = NULL;
}

/*
 Initialize indexPath field.
 */

- (void) awakeFromInsert {
	[super awakeFromInsert];
	indexPath = NULL;
}

- (NSIndexPath *) indexPath {
	if (indexPath) return indexPath;
	
	if (self.parent) indexPath = [self.parent.indexPath indexPathByAddingIndex:[self.position unsignedIntegerValue]];
	else indexPath = [NSIndexPath indexPathWithIndex:[self.position unsignedIntegerValue]];
	return indexPath;
}

+ (SUCategory *) categoryAtIndexPath:(NSIndexPath *)path inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:managedObjectContext];
	
	NSExpression *lhs = [NSExpression expressionForKeyPath:@"position"];
	NSExpression *rhs = [NSExpression expressionForConstantValue:[NSNumber numberWithUnsignedInteger:[path indexAtPosition:0]]];
	NSPredicate *positionPredicate = [[NSComparisonPredicate alloc] initWithLeftExpression:lhs
																		   rightExpression:rhs
																				  modifier:NSDirectPredicateModifier
																					  type:NSEqualToPredicateOperatorType
																				   options:0];
	lhs = [NSExpression expressionForKeyPath:@"parent"];
	rhs = [NSExpression expressionForConstantValue:[NSNull null]];
	NSPredicate *parentPredicate = [[NSComparisonPredicate alloc] initWithLeftExpression:lhs
																		 rightExpression:rhs
																				modifier:NSDirectPredicateModifier
																					type:NSEqualToPredicateOperatorType
																				 options:0];
	NSPredicate *predicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:[NSArray arrayWithObjects:parentPredicate, positionPredicate, NULL]];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = NULL;
	NSArray *objects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[positionPredicate release];
	[parentPredicate release];
	[predicate release];
	[fetchRequest release];
	
	SUCategory *category;
	if (objects && [objects count] > 0) category = [objects objectAtIndex:0];
	else return NULL;
	
	if ([path length] == 1) return category;
	else return [category categoryAtIndexPath:[path indexPathByRemovingFirstIndex] inManagedObjectContext:managedObjectContext];
}

- (SUCategory *) categoryAtIndexPath:(NSIndexPath *)path inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {	
	NSExpression *lhs = [NSExpression expressionForKeyPath:@"position"];
	NSExpression *rhs = [NSExpression expressionForConstantValue:[NSNumber numberWithUnsignedInteger:[path indexAtPosition:0]]];
	NSPredicate *predicate = [[NSComparisonPredicate alloc] initWithLeftExpression:lhs
																   rightExpression:rhs
																		  modifier:NSDirectPredicateModifier
																			  type:NSEqualToPredicateOperatorType
																		   options:NSCaseInsensitivePredicateOption];
	NSSet *objects = [self.children filteredSetUsingPredicate:predicate];
	[predicate release];
	
	SUCategory *category;
	if (objects && [objects count] == 1) category = [objects anyObject];
	else return NULL;
	
	if ([path length] == 1) return category;
	else return [category categoryAtIndexPath:[path indexPathByRemovingFirstIndex] inManagedObjectContext:managedObjectContext];	
}

+ (NSUInteger) countInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entity];
	NSError *error = NULL;
	NSUInteger numRecords = [managedObjectContext countForFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	return numRecords;
}

@end
