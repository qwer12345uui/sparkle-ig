//
//  SPKLocalizer.m
//  Sparkle
//
//  Runtime Chinese localization layer.
//
//  Why this exists
//  ---------------
//  Upstream Sparkle hard-codes every user-facing string as an English literal.
//  A survey of the built binary shows zero references to `localizedStringForKey`
//  (what NSLocalizedString expands to), `Localizable` or `lproj`, so shipping a
//  zh_Hans.strings bundle alone changes nothing on screen — the bundle is never
//  consulted. Rewriting ~450 source files to route every literal through a
//  lookup would be invasive and fragile.
//
//  Instead this module swaps English literals for their Chinese counterparts at
//  render time: it loads Sparkle.bundle's Localizable.strings into a dictionary
//  and funnels the common UIKit text entry points through it.
//
//  Safety
//  ------
//  Every lookup is a plain dictionary probe wrapped in @try/@catch. On any miss
//  or failure the ORIGINAL string is returned, so the worst case degrades to
//  stock English behaviour rather than crashing Instagram. Translation is only
//  activated when a bundled Chinese table actually exists on disk.
//

#import "SPKLocalizer.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#pragma mark - Table loading

static NSDictionary<NSString *, NSString *> * _Nullable gSPKTranslations = nil;
static BOOL gSPKTranslationsLoaded = NO;

/// Candidate locations of the bundled table. Both the rootless prefix
/// (/var/jb) and the classic one are probed, as are the hyphen and underscore
/// spellings of the Simplified Chinese folder.
static NSArray<NSString *> *SPKStringsFileCandidates(void) {
    NSArray<NSString *> *roots = @[
        @"/var/jb/Library/Application Support",
        @"/Library/Application Support"
    ];
    NSArray<NSString *> *locations = @[@"zh-Hans", @"zh_Hans", @"zh_CN"];
    NSMutableArray<NSString *> *paths = [NSMutableArray array];
    for (NSString *root in roots) {
        for (NSString *location in locations) {
            [paths addObject:[NSString stringWithFormat:@"%@/Sparkle.bundle/%@.lproj/Localizable.strings", root, location]];
        }
    }
    return paths;
}

static void SPKLoadTranslations(void) {
    if (gSPKTranslationsLoaded) {
        return;
    }
    gSPKTranslationsLoaded = YES;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *path in SPKStringsFileCandidates()) {
        if (![fileManager fileExistsAtPath:path]) {
            continue;
        }
        NSDictionary *table = [NSDictionary dictionaryWithContentsOfFile:path];
        if (table.count > 0) {
            gSPKTranslations = table;
            return;
        }
    }
}

NSString *SPKLocalizerTranslate(NSString *text) {
    if (text.length == 0) {
        return text ?: @"";
    }
    @try {
        SPKLoadTranslations();
        NSDictionary<NSString *, NSString *> *table = gSPKTranslations;
        if (!table) {
            return text;
        }
        NSString *hit = table[text];
        if (hit.length) {
            return hit;
        }
        // Some literals carry incidental leading/trailing whitespace.
        NSString *trimmed = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trimmed.length && ![trimmed isEqualToString:text]) {
            NSString *trimmedHit = table[trimmed];
            if (trimmedHit.length) {
                return trimmedHit;
            }
        }
    } @catch (__unused NSException *exception) {
        // Fall through to the untranslated string.
    }
    return text;
}

#pragma mark - Swizzling helpers

static void SPKSwizzleInstance(Class cls, SEL originalSelector, SEL replacementSelector) {
    Method original = class_getInstanceMethod(cls, originalSelector);
    Method replacement = class_getInstanceMethod(cls, replacementSelector);
    if (!original || !replacement) {
        return;
    }
    method_exchangeImplementations(original, replacement);
}

static void SPKSwizzleClass(Class cls, SEL originalSelector, SEL replacementSelector) {
    Method original = class_getClassMethod(cls, originalSelector);
    Method replacement = class_getClassMethod(cls, replacementSelector);
    if (!original || !replacement) {
        return;
    }
    method_exchangeImplementations(original, replacement);
}

#pragma mark - UIKit entry points

@interface UILabel (SPKLocalization)
- (void)spk_setText:(NSString *)text;
@end

@implementation UILabel (SPKLocalization)
- (void)spk_setText:(NSString *)text {
    [self spk_setText:SPKLocalizerTranslate(text)];
}
@end

@interface UIButton (SPKLocalization)
- (void)spk_setTitle:(NSString *)title forState:(UIControlState)state;
@end

@implementation UIButton (SPKLocalization)
- (void)spk_setTitle:(NSString *)title forState:(UIControlState)state {
    [self spk_setTitle:SPKLocalizerTranslate(title) forState:state];
}
@end

@interface UITextField (SPKLocalization)
- (void)spk_setText:(NSString *)text;
- (void)spk_setPlaceholder:(NSString *)placeholder;
@end

@implementation UITextField (SPKLocalization)
- (void)spk_setText:(NSString *)text {
    [self spk_setText:SPKLocalizerTranslate(text)];
}
- (void)spk_setPlaceholder:(NSString *)placeholder {
    [self spk_setPlaceholder:SPKLocalizerTranslate(placeholder)];
}
@end

@interface UITextView (SPKLocalization)
- (void)spk_setText:(NSString *)text;
@end

@implementation UITextView (SPKLocalization)
- (void)spk_setText:(NSString *)text {
    [self spk_setText:SPKLocalizerTranslate(text)];
}
@end

@interface UIViewController (SPKLocalization)
- (void)spk_setTitle:(NSString *)title;
@end

@implementation UIViewController (SPKLocalization)
- (void)spk_setTitle:(NSString *)title {
    [self spk_setTitle:SPKLocalizerTranslate(title)];
}
@end

@interface UIBarButtonItem (SPKLocalization)
- (void)spk_setTitle:(NSString *)title;
@end

@implementation UIBarButtonItem (SPKLocalization)
- (void)spk_setTitle:(NSString *)title {
    [self spk_setTitle:SPKLocalizerTranslate(title)];
}
@end

@interface UIAlertController (SPKLocalization)
+ (instancetype)spk_alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)style;
@end

@implementation UIAlertController (SPKLocalization)
+ (instancetype)spk_alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)style {
    return [self spk_alertControllerWithTitle:SPKLocalizerTranslate(title)
                                      message:SPKLocalizerTranslate(message)
                               preferredStyle:style];
}
@end

@interface UIAlertAction (SPKLocalization)
+ (instancetype)spk_actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^ _Nullable)(UIAlertAction *action))handler;
@end

@implementation UIAlertAction (SPKLocalization)
+ (instancetype)spk_actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^ _Nullable)(UIAlertAction *action))handler {
    return [self spk_actionWithTitle:SPKLocalizerTranslate(title) style:style handler:handler];
}
@end

#pragma mark - Loader

@implementation SPKLocalizer

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Load eagerly; if there is no bundled Chinese table we leave the
        // process completely untouched.
        SPKLoadTranslations();
        if (!gSPKTranslations) {
            return;
        }

        SPKSwizzleInstance([UILabel class], @selector(setText:), @selector(spk_setText:));
        SPKSwizzleInstance([UIButton class], @selector(setTitle:forState:), @selector(spk_setTitle:forState:));
        SPKSwizzleInstance([UITextField class], @selector(setText:), @selector(spk_setText:));
        SPKSwizzleInstance([UITextField class], @selector(setPlaceholder:), @selector(spk_setPlaceholder:));
        SPKSwizzleInstance([UITextView class], @selector(setText:), @selector(spk_setText:));
        SPKSwizzleInstance([UIViewController class], @selector(setTitle:), @selector(spk_setTitle:));
        SPKSwizzleInstance([UIBarButtonItem class], @selector(setTitle:), @selector(spk_setTitle:));
        SPKSwizzleClass([UIAlertController class], @selector(alertControllerWithTitle:message:preferredStyle:), @selector(spk_alertControllerWithTitle:message:preferredStyle:));
        SPKSwizzleClass([UIAlertAction class], @selector(actionWithTitle:style:handler:), @selector(spk_actionWithTitle:style:handler:));
    });
}

+ (NSDictionary<NSString *, NSString *> *)loadedTranslations {
    SPKLoadTranslations();
    return gSPKTranslations;
}

@end
