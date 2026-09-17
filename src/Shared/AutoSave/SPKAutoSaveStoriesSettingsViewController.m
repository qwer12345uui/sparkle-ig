#import "../../Localization/SPKLocalization.h"
#import "SPKAutoSaveStoriesSettingsViewController.h"

#import "../Instants/SPKInstantsAutoSave.h"
#import "../Messages/SPKDirectAutoSave.h"
#import "../Stories/SPKStoryAutoSave.h"
#import "SPKAutoSaveFilter.h"

@implementation SPKAutoSaveStoriesSettingsViewController

+ (SPKAutoSaveSurfaceDescriptor *)descriptor {
    static SPKAutoSaveSurfaceDescriptor *descriptor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        descriptor = [SPKAutoSaveSurfaceDescriptor new];
        descriptor.filter = SPKStoryAutoSaveFilterConfig();
        descriptor.title = SPKLocalizedString(@"Stories");
        descriptor.masterTitle = SPKLocalizedString(@"Auto-Save Stories");
        descriptor.listIcon = @"users";
        descriptor.listProvider = ^UIViewController * {
            return SPKStoryAutoSaveListViewController();
        };
        descriptor.footerProvider = ^NSString *(BOOL allMode) {
            return allMode ? [[[SPKLocalizedString(@"1. Save stories as you watch them. Stories you already have are skipped, so re-watching ") stringByAppendingString:SPKLocalizedString(@"never saves twice.\n")] stringByAppendingString:SPKLocalizedString(@"2. All Users saves every story except the users you exclude.\n")] stringByAppendingString:SPKLocalizedString(@"3. Users whose stories are never auto-saved. Add them here or from the story action menu.")]
                           : [[[SPKLocalizedString(@"1. Save stories as you watch them. Stories you already have are skipped, so re-watching ") stringByAppendingString:SPKLocalizedString(@"never saves twice.\n")] stringByAppendingString:SPKLocalizedString(@"2. Selected Users saves only the users you pick.\n")] stringByAppendingString:SPKLocalizedString(@"3. Users whose stories are auto-saved. Add them here or from the story action menu.")];
        };
    });
    return descriptor;
}

@end

@implementation SPKAutoSaveMessagesSettingsViewController

+ (SPKAutoSaveSurfaceDescriptor *)descriptor {
    static SPKAutoSaveSurfaceDescriptor *descriptor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        descriptor = [SPKAutoSaveSurfaceDescriptor new];
        descriptor.filter = SPKDirectAutoSaveFilterConfig();
        descriptor.title = SPKLocalizedString(@"Messages");
        descriptor.masterTitle = SPKLocalizedString(@"Auto-Save View-Once Media");
        descriptor.listIcon = @"messages";
        descriptor.listProvider = ^UIViewController * {
            return SPKDirectAutoSaveListViewController();
        };
        descriptor.footerProvider = ^NSString *(BOOL allMode) {
            return allMode ? [[[[SPKLocalizedString(@"1. Save view-once and replayable photos and videos as you open them. Media you already ") stringByAppendingString:SPKLocalizedString(@"have is skipped, so replaying never saves twice.\n")] stringByAppendingString:SPKLocalizedString(@"2. All Chats saves every one except in the chats you exclude.\n")] stringByAppendingString:SPKLocalizedString(@"3. Chats whose view-once media is never auto-saved. Add them here, or from the viewer's ")] stringByAppendingString:SPKLocalizedString(@"action menu and eye button menu.")]
                           : [[[[SPKLocalizedString(@"1. Save view-once and replayable photos and videos as you open them. Media you already ") stringByAppendingString:SPKLocalizedString(@"have is skipped, so replaying never saves twice.\n")] stringByAppendingString:SPKLocalizedString(@"2. Selected Chats saves only the chats you pick.\n")] stringByAppendingString:SPKLocalizedString(@"3. Chats whose view-once media is auto-saved. Add them here, or from the viewer's action ")] stringByAppendingString:SPKLocalizedString(@"menu and eye button menu.")];
        };
    });
    return descriptor;
}

@end

@implementation SPKAutoSaveInstantsSettingsViewController

+ (SPKAutoSaveSurfaceDescriptor *)descriptor {
    static SPKAutoSaveSurfaceDescriptor *descriptor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        descriptor = [SPKAutoSaveSurfaceDescriptor new];
        descriptor.filter = SPKInstantsAutoSaveFilterConfig();
        descriptor.title = SPKLocalizedString(@"Instants");
        descriptor.masterTitle = SPKLocalizedString(@"Auto-Save Instants");
        descriptor.listIcon = @"users";
        descriptor.listProvider = ^UIViewController * {
            return SPKInstantsAutoSaveListViewController();
        };
        descriptor.footerProvider = ^NSString *(BOOL allMode) {
            return allMode ? [[[SPKLocalizedString(@"1. Save instants as you open them, including each one you tap through. Instants you ") stringByAppendingString:SPKLocalizedString(@"already have are skipped.\n")] stringByAppendingString:SPKLocalizedString(@"2. All Users saves every instant except from the users you exclude.\n")] stringByAppendingString:SPKLocalizedString(@"3. Users whose instants are never auto-saved. Add them here by username.")]
                           : [[[SPKLocalizedString(@"1. Save instants as you open them, including each one you tap through. Instants you ") stringByAppendingString:SPKLocalizedString(@"already have are skipped.\n")] stringByAppendingString:SPKLocalizedString(@"2. Selected Users saves only the users you pick.\n")] stringByAppendingString:SPKLocalizedString(@"3. Users whose instants are auto-saved. Add them here by username.")];
        };
    });
    return descriptor;
}

@end
