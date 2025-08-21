#import "SNMessenger.h"

NSURL *fakeGroupContainerURL;

void createDirectoryIfNotExists(NSURL *URL) {
    if (![URL checkResourceIsReachableAndReturnError:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:URL withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

%hook NSFileManager

- (NSURL *)containerURLForSecurityApplicationGroupIdentifier:(NSString*)groupIdentifier {
	NSURL *fakeURL = [fakeGroupContainerURL URLByAppendingPathComponent:groupIdentifier];

	createDirectoryIfNotExists(fakeURL);
	createDirectoryIfNotExists([fakeURL URLByAppendingPathComponent:@"Library"]);
	createDirectoryIfNotExists([fakeURL URLByAppendingPathComponent:@"Library/Caches"]);

	return fakeURL;
}

%end

static NSString * accessGroupID() {
   	NSDictionary *query = @{
                        	(__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                        	(__bridge id)kSecAttrAccount : @"bundleSeedID",
                        	(__bridge id)kSecAttrService : @"",
                        	(__bridge id)kSecReturnAttributes : @YES
                           };

	CFDictionaryRef result = nil;
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
	if (status == errSecItemNotFound)
    	status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);

	if (status != errSecSuccess)
        return nil;

    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kSecAttrAccessGroup];
    return accessGroup;
}

%hook LSKeychainItemController

- (NSString *)accessGroup {
	return accessGroupID();
}

%end

%hook LSKeychainMultiItemController

- (NSString *)accessGroup {
	return accessGroupID();
}

%end

%hook FBKeychainItemController

- (NSString *)accessGroup {
	return accessGroupID();
}

%end

%hook FXAccountKeychainQuery

- (NSString *)accessGroup {
	return accessGroupID();
}

%end

%hook FXDeviceKeychainQuery

- (NSString *)accessGroup {
	return accessGroupID();
}

%end

%ctor {
	fakeGroupContainerURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/FakeGroupContainers"] isDirectory:YES];

	%init;
}
