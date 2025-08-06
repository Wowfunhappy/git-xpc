//
//  GTRemote.m
//  ObjectiveGitFramework
//
//  Created by Josh Abernathy on 9/12/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "GTRemote.h"

#import "NSError+Git.h"
#import "NSArray+StringArray.h"
#import "EXTScope.h"

@interface GTRemote ()

@property (nonatomic, readonly, assign) git_remote *git_remote;

@end

@implementation GTRemote

#pragma mark Lifecycle

- (id)initWithGitRemote:(git_remote *)remote {
	NSParameterAssert(remote != NULL);

	self = [super init];
	if (self == nil) return nil;

	_git_remote = remote;

	return self;
}

- (void)dealloc {
	if (_git_remote != NULL) git_remote_free(_git_remote);
}

#pragma mark NSObject

- (BOOL)isEqual:(GTRemote *)object {
	if (object == self) return YES;
	if (![object isKindOfClass:[self class]]) return NO;

	return [object.name isEqual:self.name] && [object.URLString isEqual:self.URLString];
}

- (NSUInteger)hash {
	return self.name.hash ^ self.URLString.hash;
}

#pragma mark Properties

- (NSString *)name {
	const char *name = git_remote_name(self.git_remote);
	if (name == NULL) return nil;

	return @(name);
}

- (NSString *)URLString {
	const char *URLString = git_remote_url(self.git_remote);
	if (URLString == NULL) return nil;

	return @(URLString);
}

- (NSArray *)fetchRefspecs {
	__block git_strarray refspecs;
	int gitError = git_remote_get_fetch_refspecs(&refspecs, self.git_remote);
	if (gitError != GIT_OK) return nil;

	@onExit {
		git_strarray_free(&refspecs);
	};

	return [NSArray git_arrayWithStrarray:refspecs];

}

#pragma mark Update the remote

- (BOOL)saveRemote:(NSError **)error {
	// In libgit2 1.3.2, git_remote_save() has been removed
	// Configuration changes are saved automatically
	return YES;
}

- (BOOL)updateURLString:(NSString *)URLString error:(NSError **)error {
	NSParameterAssert(URLString != nil);

	if ([self.URLString isEqualToString:URLString]) return YES;

	// In libgit2 1.3.2, git_remote_set_url requires repository and remote name
	git_repository *repo = git_remote_owner(self.git_remote);
	const char *remoteName = git_remote_name(self.git_remote);
	int gitError = git_remote_set_url(repo, remoteName, URLString.UTF8String);
	if (gitError != GIT_OK) {
		if (error != NULL) {
			*error = [NSError git_errorFor:gitError description:@"Failed to update remote URL string."];
		}
		return NO;
	}
	return [self saveRemote:error];
}

- (BOOL)addFetchRefspec:(NSString *)fetchRefspec error:(NSError **)error {
	NSParameterAssert(fetchRefspec != nil);

	if ([self.fetchRefspecs containsObject:fetchRefspec]) return YES;

	// In libgit2 1.3.2, git_remote_add_fetch requires repository and remote name
	git_repository *repo = git_remote_owner(self.git_remote);
	const char *remoteName = git_remote_name(self.git_remote);
	int gitError = git_remote_add_fetch(repo, remoteName, fetchRefspec.UTF8String);
	if (gitError != GIT_OK) {
		if (error != NULL) {
			*error = [NSError git_errorFor:gitError description:@"Failed to add fetch refspec."];
		}
		return NO;
	}
	return [self saveRemote:error];
}

@end
