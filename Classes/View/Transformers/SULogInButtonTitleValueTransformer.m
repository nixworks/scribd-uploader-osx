#import "SULogInButtonTitleValueTransformer.h"

@implementation SULogInButtonTitleValueTransformer

/*
 This transformer converts between session keys (strings) and button titles
 (strings).
 */

+ (Class) transformedValueClass {
	return [NSString class];
}

/*
 This is a one-way value transformer.
 */

+ (BOOL) allowsReverseTransformation {
	return NO;
}

/*
 Given a session key, transforms it into a title for the Log In/Log Out button.
 */

- (id) transformedValue:(id)value {
	return value ? @"Switch Users" : @"Log In";
}

@end
