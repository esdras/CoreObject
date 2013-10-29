#import "COCommand.h"

@class CORevision;

@interface COCommandSetCurrentVersionForBranch : COSingleCommand
{
    ETUUID *_branchUUID;
    ETUUID *_oldRevisionUUID;
    ETUUID *_newRevisionUUID;
	
	ETUUID *_oldHeadRevisionUUID;
    ETUUID *_newHeadRevisionUUID;
}


/** @taskunit Basic Properties */


@property (nonatomic, copy) ETUUID *branchUUID;
@property (nonatomic, copy) ETUUID *oldRevisionUUID;
@property (nonatomic, copy) ETUUID *revisionUUID;

@property (nonatomic, copy) ETUUID *oldHeadRevisionUUID;
@property (nonatomic, copy) ETUUID *headRevisionUUID;


@property (nonatomic, readonly) CORevision *oldRevision;
@property (nonatomic, readonly) CORevision *revision;


/** @taskunit Track Node Protocol */


/** 
 * Returns the set revision UUID. 
 */
- (ETUUID *)UUID;
/**
 * Returns the concerned branch UUID.
 */
- (ETUUID *)branchUUID;
/**
 * Returns the set revision metadata.
 *
 * See -[CORevision metadata].
 */
- (NSDictionary *)metadata;
/**
 * Returns the short description for the set revision.
 *
 * See -[CORevision localizedShortDescription].
 */
- (NSString *)localizedShortDescription;

@end
