//
//  SPKLocalization.h
//  Sparkle
//
//  Runtime Simplified-Chinese layer built directly into the tweak binary.
//
//  The upstream project hard codes English copy. Rather than mutate UIKit text
//  objects after the fact we hand every user visible literal through
//  SPKLocalizedString() where it is created, so the transform is exhaustive and
//  never fights the host app's own text plumbing.
//
//  The table is embedded as a base64 encoded binary plist, which keeps the dylib
//  self contained: injecting it standalone (TrollFools etc.) renders Chinese with
//  no Sparkle.bundle present on disk.
//

#ifndef SPARKLE_LOCALIZATION_H
#define SPARKLE_LOCALIZATION_H

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Maps a legacy layout path onto its rootless (/var/jb) counterpart.
FOUNDATION_EXPORT NSString *SPKJailbreakPath(NSString *path);

/// English -> Simplified Chinese table compiled into the binary.
FOUNDATION_EXPORT NSDictionary<NSString *, NSString *> *SPKEmbeddedSimplifiedChineseTranslations(void);

/// Returns the Simplified Chinese rendering of `text`, falling back to `text`.
FOUNDATION_EXPORT NSString *SPKLocalizedString(NSString *text);

NS_ASSUME_NONNULL_END

#endif /* SPARKLE_LOCALIZATION_H */
