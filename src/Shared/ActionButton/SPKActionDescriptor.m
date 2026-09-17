#import "../../Localization/SPKLocalization.h"
#import "SPKActionDescriptor.h"
#import "ActionButtonCore.h"

@implementation SPKActionDescriptor

+ (instancetype)descriptorWithIdentifier:(NSString *)identifier
                                   title:(NSString *)title
                                iconName:(NSString *)iconName {
    SPKActionDescriptor *descriptor = [[self alloc] init];
    descriptor.identifier = identifier;
    descriptor.title = title;
    descriptor.iconName = iconName;
    return descriptor;
}

+ (NSArray<SPKActionDescriptor *> *)descriptors {
    static NSArray<SPKActionDescriptor *> *descriptors = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        descriptors = @[
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionDownloadLibrary
                                                    title:SPKLocalizedString(@"Save to Photos")
                                                 iconName:@"download"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionDownloadShare
                                                    title:@"Share"
                                                 iconName:@"share"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionCopyDownloadLink
                                                    title:SPKLocalizedString(@"Copy Download URL")
                                                 iconName:@"link"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionCopyMedia
                                                    title:SPKLocalizedString(@"Copy Media")
                                                 iconName:@"copy"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionDownloadGallery
                                                    title:SPKLocalizedString(@"Save to Gallery")
                                                 iconName:@"sparkle_gallery"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionTrimSave
                                                    title:SPKLocalizedString(@"Trim & Save")
                                                 iconName:@"trim"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionEditSave
                                                    title:SPKLocalizedString(@"Edit & Save")
                                                 iconName:@"crop"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionDownloadAudio
                                                    title:SPKLocalizedString(@"Save Audio to Files")
                                                 iconName:@"audio_download"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionDownloadAudioShare
                                                    title:SPKLocalizedString(@"Share Audio")
                                                 iconName:@"share"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionDownloadAudioGallery
                                                    title:SPKLocalizedString(@"Save Audio to Gallery")
                                                 iconName:@"sparkle_gallery"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionPlayAudio
                                                    title:SPKLocalizedString(@"Play Audio")
                                                 iconName:@"play"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionCopyAudioURL
                                                    title:SPKLocalizedString(@"Copy Audio Download URL")
                                                 iconName:@"link"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionDownloadAllLibrary
                                                    title:SPKLocalizedString(@"Save All to Photos")
                                                 iconName:@"download"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionDownloadAllShare
                                                    title:SPKLocalizedString(@"Share All")
                                                 iconName:@"share"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionDownloadAllGallery
                                                    title:SPKLocalizedString(@"Save All to Gallery")
                                                 iconName:@"sparkle_gallery"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionDownloadAllClipboard
                                                    title:SPKLocalizedString(@"Copy All Media")
                                                 iconName:@"copy"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionDownloadAllLinks
                                                    title:SPKLocalizedString(@"Copy Download URLs")
                                                 iconName:@"link"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionDownloadAll
                                                    title:SPKLocalizedString(@"Download All")
                                                 iconName:@"more"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionExpand
                                                    title:@"Expand"
                                                 iconName:@"expand"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionViewThumbnail
                                                    title:SPKLocalizedString(@"View Thumbnail")
                                                 iconName:@"photo_gallery"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionCopyCaption
                                                    title:SPKLocalizedString(@"Copy Caption")
                                                 iconName:@"caption"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionOpenTopicSettings
                                                    title:SPKLocalizedString(@"Settings")
                                                 iconName:@"settings"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionDeletedMessagesLog
                                                    title:SPKLocalizedString(@"Deleted Messages")
                                                 iconName:@"channels"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionRepost
                                                    title:@"Repost"
                                                 iconName:@"repost"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionToggleStorySeenUserRule
                                                    title:SPKLocalizedString(@"Toggle Story User Rule")
                                                 iconName:@"eye"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionToggleStoryAutoSaveUserRule
                                                    title:SPKLocalizedString(@"Toggle Story Auto-Save")
                                                 iconName:@"download"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionToggleDirectAutoSaveThreadRule
                                                    title:SPKLocalizedString(@"Toggle Chat Auto-Save")
                                                 iconName:@"download"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionToggleProfileStorySeenUserRule
                                                    title:SPKLocalizedString(@"Toggle Story Seen")
                                                 iconName:@"eye"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionToggleProfileMessagesSeenUserRule
                                                    title:SPKLocalizedString(@"Toggle Messages Seen")
                                                 iconName:@"eye"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionStoryMentionsSheet
                                                    title:SPKLocalizedString(@"Story Mentions")
                                                 iconName:@"mention"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionProfileCopyInfo
                                                    title:SPKLocalizedString(@"Copy Info")
                                                 iconName:@"info"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionProfileCopyID
                                                    title:SPKLocalizedString(@"Copy ID")
                                                 iconName:@"key"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionProfileCopyUsername
                                                    title:SPKLocalizedString(@"Copy Username")
                                                 iconName:@"username"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionProfileCopyName
                                                    title:SPKLocalizedString(@"Copy Name")
                                                 iconName:@"text"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionProfileCopyBio
                                                    title:SPKLocalizedString(@"Copy Bio")
                                                 iconName:@"caption"],
            [SPKActionDescriptor descriptorWithIdentifier:kSPKActionProfileCopyLink
                                                    title:SPKLocalizedString(@"Copy Profile URL")
                                                 iconName:@"link"],
            [SPKActionDescriptor descriptorWithIdentifier:@"more"
                                                    title:@"More"
                                                 iconName:@"more"],
            [SPKActionDescriptor descriptorWithIdentifier:@"action"
                                                    title:@"Actions"
                                                 iconName:@"action"]
        ];
    });
    return descriptors;
}

+ (nullable instancetype)descriptorForIdentifier:(NSString *)identifier {
    for (SPKActionDescriptor *descriptor in [self descriptors]) {
        if ([descriptor.identifier isEqualToString:identifier]) {
            return descriptor;
        }
    }
    return nil;
}

+ (NSArray<SPKActionDescriptor *> *)availableSectionIconDescriptors {
    return @[
        [SPKActionDescriptor descriptorWithIdentifier:@"action"
                                                title:@"Actions"
                                             iconName:@"action"],
        [SPKActionDescriptor descriptorWithIdentifier:@"copy"
                                                title:@"Copy"
                                             iconName:@"copy"],
        [SPKActionDescriptor descriptorWithIdentifier:@"key"
                                                title:@"Key"
                                             iconName:@"key"],
        [SPKActionDescriptor descriptorWithIdentifier:@"caption"
                                                title:@"Caption"
                                             iconName:@"caption"],
        [SPKActionDescriptor descriptorWithIdentifier:@"download"
                                                title:@"Download"
                                             iconName:@"download"],
        [SPKActionDescriptor descriptorWithIdentifier:@"share"
                                                title:@"Share"
                                             iconName:@"share"],
        [SPKActionDescriptor descriptorWithIdentifier:@"link"
                                                title:@"Link"
                                             iconName:@"link"],
        [SPKActionDescriptor descriptorWithIdentifier:@"media"
                                                title:SPKLocalizedString(@"Gallery")
                                             iconName:@"sparkle_gallery"],
        [SPKActionDescriptor descriptorWithIdentifier:@"expand"
                                                title:@"Expand"
                                             iconName:@"expand"],
        [SPKActionDescriptor descriptorWithIdentifier:@"photo_gallery"
                                                title:@"Thumbnail"
                                             iconName:@"photo_gallery"],
        [SPKActionDescriptor descriptorWithIdentifier:@"repost"
                                                title:@"Repost"
                                             iconName:@"repost"],
        [SPKActionDescriptor descriptorWithIdentifier:@"mention"
                                                title:@"Mentions"
                                             iconName:@"mention"],
        [SPKActionDescriptor descriptorWithIdentifier:@"feed"
                                                title:SPKLocalizedString(@"Feed")
                                             iconName:@"feed"],
        [SPKActionDescriptor descriptorWithIdentifier:@"reels"
                                                title:SPKLocalizedString(@"Reels")
                                             iconName:@"reels"],
        [SPKActionDescriptor descriptorWithIdentifier:@"story"
                                                title:SPKLocalizedString(@"Stories")
                                             iconName:@"story"],
        [SPKActionDescriptor descriptorWithIdentifier:@"messages"
                                                title:SPKLocalizedString(@"Messages")
                                             iconName:@"messages"],
        [SPKActionDescriptor descriptorWithIdentifier:@"profile"
                                                title:SPKLocalizedString(@"Profile")
                                             iconName:@"user_circle"],
        [SPKActionDescriptor descriptorWithIdentifier:@"settings"
                                                title:SPKLocalizedString(@"Settings")
                                             iconName:@"settings"],
        [SPKActionDescriptor descriptorWithIdentifier:@"more"
                                                title:@"More"
                                             iconName:@"more"]
    ];
}

@end

NSString *SPKActionDescriptorDisplayTitle(NSString *identifier, NSString *topicTitle) {
    if ([identifier isEqualToString:kSPKActionOpenTopicSettings] && topicTitle.length > 0) {
        return [NSString stringWithFormat:SPKLocalizedString(@"%@ Settings"), topicTitle];
    }
    SPKActionDescriptor *descriptor = [SPKActionDescriptor descriptorForIdentifier:identifier];
    return descriptor.title ?: @"Action";
}

NSString *SPKActionDescriptorIconName(NSString *identifier) {
    SPKActionDescriptor *descriptor = [SPKActionDescriptor descriptorForIdentifier:identifier];
    return descriptor.iconName ?: @"action";
}
