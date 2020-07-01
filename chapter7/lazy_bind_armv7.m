#include <Foundation/Foundation.h>
#include <stdio.h>
#include <mach-o/dyld.h>
#include <mach/mach.h>

int main(){

		NSLog(@"test");
		NSLog(@"test2");

		printf("test3\n");

		intptr_t base_addr = _dyld_get_image_vmaddr_slide(0);
		const struct mach_header *image_addr = _dyld_get_image_header(0);

		printf("base_addr %lx\n", base_addr);
		printf("image_addr %lx\n", (long)image_addr);

        return 0;
}
