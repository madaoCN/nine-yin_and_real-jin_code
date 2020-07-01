/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.

%hook ClassName

// Hooking a class method
+ (id)sharedInstance {
	return %orig;
}

// Hooking an instance method with an argument.
- (void)messageName:(int)argument {
	%log; // Write a message about this call, including its class, name and arguments, to the system log.

	%orig; // Call through to the original function with its original arguments.
	%orig(nil); // Call through to the original function with a custom argument.

	// If you use %orig(), you MUST supply all arguments (except for self and _cmd, the automatically generated ones.)
}

// Hooking an instance method with no arguments.
- (id)noArguments {
	%log;
	id awesome = %orig;
	[awesome doSomethingElse];

	return awesome;
}

// Always make sure you clean up after yourself; Not doing so could have grave consequences!
%end
*/

#include <MobileGestalt/MobileGestalt.h>
#include <substrate.h>
#import <AdSupport/AdSupport.h>

#import "PSSpecifier.h"

%hook PSListController

-(NSArray*) specifiers {

		NSLog(@"specifiers");

        NSArray *array = %orig;  //执行原始代码，获取数组里的数据

        NSLog(@"count %lu array %@",(unsigned long)array.count, array);

        PSSpecifier *oldPSSpecifier = array[4];  //取原始数据的第 4 个数据

        NSLog(@"array 4 obj %@", oldPSSpecifier);
        NSLog(@"array 4 name %@", oldPSSpecifier.name);
        NSLog(@"array 4 id %@", oldPSSpecifier.identifier);
        NSLog(@"array 4 target %@", oldPSSpecifier.target);

        //获取 UDID
        CFTypeRef result = MGCopyAnswer((__bridge CFStringRef)@"UniqueDeviceID");
        NSString *strUDID = (__bridge NSString *)(result);
        NSString *strCellName = [NSString stringWithFormat:@"UDID %@", strUDID];

        //添加 UDID 的 PSSpecifier
        PSSpecifier *newPSSpecifier = oldPSSpecifier;  //将原始的第 4 个数据给 newPSSpecifier
        newPSSpecifier.name = strCellName;
        newPSSpecifier.identifier = @"UDID";
        newPSSpecifier.target = 0;
        
        //获取 IDFA
        NSString *strIDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        NSString *strCellName2 = [NSString stringWithFormat:@"IDFA %@", strIDFA];

        //添加 IDFA 的 PSSpecifier
     	PSSpecifier *newPSSpecifier2 = array[5];;  //将原始的第 5 个数据给 newPSSpecifier
        newPSSpecifier2.name = strCellName2;
        newPSSpecifier2.identifier = @"IDFA";
        newPSSpecifier2.target = 0;

        return array;
}

%end