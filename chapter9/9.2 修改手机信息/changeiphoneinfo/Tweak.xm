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
#import <sys/utsname.h>

static CFTypeRef (*orig_MGCopyAnswer)(CFStringRef str);
static CFTypeRef (*orig_MGCopyAnswer_internal)(CFStringRef str, uint32_t* outTypeCode);
static int (*orig_uname)(struct utsname *);

CFTypeRef new_MGCopyAnswer(CFStringRef str);
CFTypeRef new_MGCopyAnswer_internal(CFStringRef str, uint32_t* outTypeCode);
int new_uname(struct utsname *systemInfo);

int new_uname(struct utsname * systemInfo){

    NSLog(@"new_uname");
    int nRet = orig_uname(systemInfo);

    char str_machine_name[100] = "iPhone8,1";
    strcpy(systemInfo->machine,str_machine_name);

    return nRet;
}

CFTypeRef new_MGCopyAnswer(CFStringRef str){

    //NSLog(@"new_MGCopyAnswer");
    //NSLog(@"str: %@",str);

    NSString *keyStr = (__bridge NSString *)str;
    if ([keyStr isEqualToString:@"UniqueDeviceID"] ) {

        NSString *strUDID = @"57359dc2fa451304bd9f94f590d02068d563d283";
        return (CFTypeRef)strUDID;
    }
    else if ([keyStr isEqualToString:@"SerialNumber"] ) {

        NSString *strSerialNumber = @"DNPJD17NDTTP";
        return (CFTypeRef)strSerialNumber;
    }
    else if ([keyStr isEqualToString:@"WifiAddress"] ) {

        NSString *strWifiAddress = @"98:FE:94:1F:30:0A";
        return (CFTypeRef)strWifiAddress;
    }
    else if ([keyStr isEqualToString:@"BluetoothAddress"] ) {

        NSString *strBlueAddress = @"98:FE:94:1F:30:0B";
        return (CFTypeRef)strBlueAddress;
    }
    else if([keyStr isEqualToString:@"ProductVersion"]) {

        NSString *strProductVersion = @"10.3.3";
        return (CFTypeRef)strProductVersion;
    }
    else if([keyStr isEqualToString:@"UserAssignedDeviceName"]) {

        NSString *strUserAssignedDeviceName = @"Dev iPhone";
        return (CFTypeRef)strUserAssignedDeviceName;
    }
    return orig_MGCopyAnswer(str);
}

CFTypeRef new_MGCopyAnswer_internal(CFStringRef str, uint32_t* outTypeCode) {

    //NSLog(@"new_MGCopyAnswer_internal");
    //NSLog(@"str: %@",str);

    NSString *keyStr = (__bridge NSString *)str;
    if ([keyStr isEqualToString:@"UniqueDeviceID"] ) {

        NSString *strUDID = @"57359dc2fa451304bd9f94f590d02068d563d283";
        return (CFTypeRef)strUDID;
    }
    else if ([keyStr isEqualToString:@"SerialNumber"] ) {

        NSString *strSerialNumber = @"DNPJD17NDTTP";
        return (CFTypeRef)strSerialNumber;
    }
    else if ([keyStr isEqualToString:@"WifiAddress"] ) {

        NSString *strWifiAddress = @"98:FE:94:1F:30:0A";
        return (CFTypeRef)strWifiAddress;
    }
    else if ([keyStr isEqualToString:@"BluetoothAddress"] ) {

        NSString *strBlueAddress = @"98:FE:94:1F:30:0B";
        return (CFTypeRef)strBlueAddress;
    }
    else if([keyStr isEqualToString:@"ProductVersion"]) {

        NSString *strProductVersion = @"10.3.3";
        return (CFTypeRef)strProductVersion;
    }
    else if([keyStr isEqualToString:@"UserAssignedDeviceName"]) {

        NSString *strUserAssignedDeviceName = @"Dev iPhone";
        return (CFTypeRef)strUserAssignedDeviceName;
    }

    return orig_MGCopyAnswer_internal(str, outTypeCode);
}

void hook_uname(){

    NSLog(@"hook_uname");
    char str_libsystem_c[100] = {0};
    strcpy(str_libsystem_c, "/usr/lib/libsystem_c.dylib");

    void *h = dlopen(str_libsystem_c, RTLD_GLOBAL);
    if(h != 0){

        MSImageRef ref = MSGetImageByName(str_libsystem_c);
        void * unameFn = MSFindSymbol(ref, "_uname");
        NSLog(@"unameFn");
        MSHookFunction(unameFn, (void *) new_uname, (void **)& orig_uname);
    }
	else {

    	strcpy(str_libsystem_c, "/usr/lib/system/libsystem_c.dylib");
    	h = dlopen(str_libsystem_c, RTLD_GLOBAL);
		if(h != 0){

			MSImageRef ref = MSGetImageByName(str_libsystem_c);
			void * unameFn = MSFindSymbol(ref, "_uname");
			NSLog(@"unameFn");
			MSHookFunction(unameFn, (void *) new_uname, (void **)& orig_uname);
		}
		else {

			NSLog(@"%s dlopen error", str_libsystem_c);
		}
	}
}

void hookMGCopyAnswer(){

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

%hook ASIdentifierManager
//idfa
-(NSUUID*)advertisingIdentifier{

    NSUUID *uuid = [[NSUUID alloc] init];
    return uuid;
}
%end

%hook UIDevice
//idfv
-(NSUUID*)identifierForVendor{

    NSUUID *uuid = [[NSUUID alloc] init];
    return uuid;
}
%end

%ctor{

	hookMGCopyAnswer();
    hook_uname();
}
