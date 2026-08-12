#import "SatellaPrefsRootless.h"

#import <rootless.h>

NSArray<NSString *> *SatellaPrefsAuthorizedBundleIdentifiers(void) {
    NSString *filterPath = ROOT_PATH_NS(@"/Library/MobileSubstrate/DynamicLibraries/Satella.plist");
    NSDictionary *propertyList = [NSDictionary dictionaryWithContentsOfFile:filterPath];
    id bundles = propertyList[@"Filter"][@"Bundles"];
    if (![bundles isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<NSString *> *validated = [NSMutableArray array];
    for (id value in (NSArray *)bundles) {
        if ([value isKindOfClass:NSString.class] && ![value hasPrefix:@"com.apple."]) {
            [validated addObject:value];
        }
    }
    return validated.copy;
}

BOOL SatellaPrefsMirrorPreferences(NSDictionary<NSString *, id> *preferences) {
    NSString *path = ROOT_PATH_NS(@"/var/mobile/Library/Preferences/emt.paisseon.satella.plist");
    NSString *directory = path.stringByDeletingLastPathComponent;
    NSError *directoryError = nil;
    if (![NSFileManager.defaultManager createDirectoryAtPath:directory
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:&directoryError]) {
        NSLog(@"[SatellaPrefs] Could not create preference mirror directory: %@", directoryError);
        return NO;
    }

    NSError *serializationError = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:preferences
                                                               format:NSPropertyListBinaryFormat_v1_0
                                                              options:0
                                                                error:&serializationError];
    if (data == nil) {
        NSLog(@"[SatellaPrefs] Could not serialize preferences: %@", serializationError);
        return NO;
    }

    NSError *writeError = nil;
    BOOL wrote = [data writeToFile:path options:NSDataWritingAtomic error:&writeError];
    if (!wrote) {
        NSLog(@"[SatellaPrefs] Could not mirror preferences: %@", writeError);
    }
    return wrote;
}
