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

#include <substrate.h>

static CFTypeRef (*orig_MGCopyAnswer)(CFStringRef str);
static CFTypeRef (*orig_MGCopyAnswer_internal)(CFStringRef str, uint32_t* outTypeCode);

CFTypeRef new_MGCopyAnswer(CFStringRef str);
CFTypeRef new_MGCopyAnswer_internal(CFStringRef str, uint32_t* outTypeCode);

CFTypeRef new_MGCopyAnswer(CFStringRef str){

    NSLog(@"new_MGCopyAnswer");

    NSString *keyStr = (__bridge NSString *)str;
    if ([keyStr isEqualToString:@"SerialNumber"] ) {

        NSString *strSerialNumber = @"ABCDEF123456";
        return (CFTypeRef)strSerialNumber;
    }
    return orig_MGCopyAnswer(str);
}

CFTypeRef new_MGCopyAnswer_internal(CFStringRef str, uint32_t* outTypeCode) {

    NSLog(@"new_MGCopyAnswer_internal");

    NSString *keyStr = (__bridge NSString *)str;
    if ([keyStr isEqualToString:@"SerialNumber"] ) {

        NSString *strSerialNumber = @"ABCDEF123456";
        return (CFTypeRef)strSerialNumber;
    }
    return orig_MGCopyAnswer_internal(str, outTypeCode);
}

%ctor{

    char *dylib_path = (char*)"/usr/lib/libMobileGestalt.dylib";
    void *h = dlopen(dylib_path, RTLD_GLOBAL);
    if (h != 0) {

        MSImageRef ref = MSGetImageByName(dylib_path);
        void * MGCopyAnswerFn = MSFindSymbol(ref, "_MGCopyAnswer");

        uint8_t MGCopyAnswer_arm64_impl[8] = {0x01, 0x00, 0x80, 0xd2, 0x01, 0x00, 0x00, 0x14};

        //如果找到特征码表示是 64 位，否则是 32 位就直接 Hook
        if (memcmp(MGCopyAnswerFn, MGCopyAnswer_arm64_impl, 8) == 0) {

            MSHookFunction((void*)((uint8_t*)MGCopyAnswerFn + 8), (void*)new_MGCopyAnswer_internal, (void**)&orig_MGCopyAnswer_internal);
        }
        else{

            MSHookFunction(MGCopyAnswerFn, (void *) new_MGCopyAnswer, (void **)& orig_MGCopyAnswer);
        }
    }
}
