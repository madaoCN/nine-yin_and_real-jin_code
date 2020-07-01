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

#import <substrate.h>
#import <sys/sysctl.h>

#include <mach/task.h>
#include <mach/mach_init.h>

#include <unistd.h>

// For ioctl
#include <termios.h>
#include <sys/ioctl.h>

static int (*orig_ptrace) (int request, pid_t pid, caddr_t addr, int data);
static int my_ptrace (int request, pid_t pid, caddr_t addr, int data){
    if(request == 31){
		NSLog(@"[my_ptrace] ptrace request is PT_DENY_ATTACH");
		return 0;
	}
	return orig_ptrace(request,pid,addr,data);
}

static void* (*orig_dlsym)(void* handle, const char* symbol);
static void* my_dlsym(void* handle, const char* symbol){
	if(strcmp(symbol, "ptrace") == 0){
		NSLog(@"[my_dlsym] dlsym get ptrace symbol");
		return (void*)my_ptrace;
    }
   	return orig_dlsym(handle, symbol);
}

static int (*orig_sysctl)(int * name, u_int namelen, void * info, size_t * infosize, void * newinfo, size_t newinfosize);
static int my_sysctl(int * name, u_int namelen, void * info, size_t * infosize, void * newinfo, size_t newinfosize){
	int ret = orig_sysctl(name,namelen,info,infosize,newinfo,newinfosize);
	if(namelen == 4 && name[0] == 1 && name[1] == 14 && name[2] == 1){
		struct kinfo_proc *info_ptr = (struct kinfo_proc *)info;
        if(info_ptr && (info_ptr->kp_proc.p_flag & P_TRACED) != 0){
            NSLog(@"[my_sysctl] sysctl query trace status.");
            info_ptr->kp_proc.p_flag ^= P_TRACED;
            if((info_ptr->kp_proc.p_flag & P_TRACED) == 0){
                NSLog(@"[my_sysctl] trace status reomve success!");
            }
        }
	}
	return ret;
}

static void* (*orig_syscall)(int code, va_list args);
static void* my_syscall(int code, va_list args){
	int request;
    va_list newArgs;
    va_copy(newArgs, args);
    if(code == 26){
        request = (long)args;
        if(request == 31){
            NSLog(@"[my_syscall] syscall call ptrace, and request is PT_DENY_ATTACH");
            return nil;
        }
    }
    return (void*)orig_syscall(code, newArgs);
}

static kern_return_t (*orig_task_get_exception_ports) (task_t task, exception_mask_t exception_mask, exception_mask_array_t masks, mach_msg_type_number_t *masksCnt, exception_handler_array_t old_handlers, exception_behavior_array_t old_behaviors, exception_flavor_array_t old_flavors);

static kern_return_t my_task_get_exception_ports (task_t task, exception_mask_t exception_mask, exception_mask_array_t masks, mach_msg_type_number_t *masksCnt, exception_handler_array_t old_handlers, exception_behavior_array_t old_behaviors, exception_flavor_array_t old_flavors) {
    
    *masksCnt = 0;
    NSLog(@"[my_task_get_exception_ports]");
    return 1;
}

int (*orig_isatty)(int num);

int my_isatty(int num){
    NSLog(@"[my_isatty]");
    return 0;
}

int (*orig_ioctl)(int num, unsigned long num2, ...);

int my_ioctl(int num, unsigned long num2, ...){
    
    if (num == 1 && num2 == TIOCGWINSZ) {

        NSLog(@"[my_ioctl]");
        return 1;
    }
    return orig_ioctl(num,num2);
}
%ctor{
	MSHookFunction((void *)MSFindSymbol(NULL,"_ptrace"),(void*)my_ptrace,(void**)&orig_ptrace);
	MSHookFunction((void *)dlsym,(void*)my_dlsym,(void**)&orig_dlsym);
	MSHookFunction((void *)sysctl,(void*)my_sysctl,(void**)&orig_sysctl);
	MSHookFunction((void *)syscall,(void*)my_syscall,(void**)&orig_syscall);
    
    MSHookFunction((void *)task_get_exception_ports,(void*)my_task_get_exception_ports,(void**)&orig_task_get_exception_ports);
    MSHookFunction((void *)isatty,(void*)my_isatty,(void**)&orig_isatty);
    MSHookFunction((void *)ioctl,(void*)my_ioctl,(void**)&orig_ioctl);

	NSLog(@"[Bypass antiDebugging] load");
}

