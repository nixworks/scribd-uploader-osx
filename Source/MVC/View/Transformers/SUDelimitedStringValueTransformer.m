#import "SUDelimitedStringValueTransformer.h"

@implementation SUDelimitedStringValueTransformer

#pragma mark Properties

@synthesize delimiter;

#pragma mark Initializing and deallocating

- (id) init {
	return [self initWithDelimiter:@","];
}

- (id) initWithDelimiter:(NSString *)delim {
	if (self = [super init]) {
		self.delimiter = delim;
	}
	return self;
}

#pragma mark Value transformer

/*
 This transformer converts between different subclasses of NSObject.
 */

+ (Class) transformedValueClass {
	return [NSObject class];
}

/*
 This is a bidirectional transformer.
 */

+ (BOOL) allowsReverseTransformation {
	return YES;
}

/*
 Splits a string on the delimiter to form an array.
 */

- (id) transformedValue:(id)value {
	if ([value isKindOfClass:[NSString class]])
		return [(NSString *)(value) componentsSeparatedByString:self.delimiter];
	else return value;
}

/*
 Joins an array's elements on the delimiter to form a string.
 */

- (id) reverseTransformedValue:(id)value {
	if ([value isKindOfClass:[NSArray class]]) {
		if ([(NSArray *)value count]) return [(NSArray *)(value) componentsJoinedByString:self.delimiter];
		else return NULL;
	}
	else return value;
}

@end
