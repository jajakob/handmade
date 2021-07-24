#include <stdio.h>
#include <stdint.h> 


#include <objc/runtime.h>
#include <objc/message.h>
#include <CoreGraphics/CGGeometry.h>

#define CLS objc_getClass
#define SELC sel_getUid
#define MSG ((id (*)(id, SEL, ...))objc_msgSend)
#define CLS_MSG ((id (*)(Class, SEL, ...))objc_msgSend)

#define internal static
#define local_persist static
#define global_variable static

global_variable Class NSWindowC;

global_variable SEL allocSel;
global_variable SEL allocSel;
global_variable SEL initSel;


enum NSWindowStyleMask {
    NSWindowStyleMaskBorderless = 0,
    NSWindowStyleMaskTitled = 1 << 0,
    NSWindowStyleMaskClosable = 1 << 1,
    NSWindowStyleMaskMiniaturizable = 1 << 2,
    NSWindowStyleMaskResizable = 1 << 3
};

int main() {

    NSWindowC = CLS("NSWindow"); 
    allocSel = SELC("alloc");
    initSel = SELC("init");

    // // typedef CGRect NSRect;
    CGRect frame = {0, 0, 600, 500};

    id window = MSG(
        CLS_MSG(NSWindowC, allocSel), 
        SELC("initWithContentRect:styleMask:backing:defer:"),
        frame,
        NSWindowStyleMaskTitled|
        NSWindowStyleMaskClosable|
        NSWindowStyleMaskMiniaturizable|
        NSWindowStyleMaskResizable,
        2, // NSBackingStoreBuffered
        false
    );

    
    // [window setBackgroundColor: NSColor.redColor];
    // MSG(window, SELC("setBackgroundColor:", )

    // [window makeKeyAndOrderFront: nil];
    MSG(window, SELC("makeKeyAndOrderFront:"), NULL);
    // [window setDelegate: mainWindowDelegate];

    MSG(window, SELC("setTitle:"), CLS_MSG(CLS("NSString"), SELC("stringWithUTF8String:"), "Handmade"));

    id app = CLS_MSG(CLS("NSApplication"), SELC("sharedApplication"));
    
    
    // MSG(app, SELC("run"));

    


    return 0;
}