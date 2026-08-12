#import "SatellaPrefsRootless.h"

#import <rootless.h>

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
