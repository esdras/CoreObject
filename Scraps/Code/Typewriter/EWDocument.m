#import "EWAppDelegate.h"
#import "EWDocument.h"
#import "EWUndoManager.h"
#import "EWTypewriterWindowController.h"
#import "EWBranchesWindowController.h"
#import "EWPickboardWindowController.h"
#import "EWHistoryWindowController.h"
#import <EtoileFoundation/Macros.h>

#import <CoreObject/CoreObject.h>
#import <CoreObject/COEditingContext+Private.h>

@implementation EWDocument

- (id)initWithPersistentRoot: (COPersistentRoot *)aRoot title: (NSString *)aTitle
{
    SUPERINIT;

    assert(aRoot != nil);
    assert([aRoot rootObject] != nil);

    _title = aTitle;
    _persistentRoot = aRoot;

    EWUndoManager *myUndoManager = [[EWUndoManager alloc] init];
    [myUndoManager setDelegate: self];
    [self setUndoManager: (NSUndoManager *)myUndoManager];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(storePersistentRootMetadataDidChange:)
                                                 name: COPersistentRootDidChangeNotification
                                               object: _persistentRoot];

    return self;
}

- (id)init
{
    [NSException raise: NSIllegalSelectorException
                format: @"use -initWithPersistentRoot:, not -init"];
    return nil;
//    
//    COPersistentRoot *aRoot = [[[NSApp delegate] editingContext] insertNewPersistentRootWithEntityName: @"Anonymous.TypewriterDocument"];
//    [aRoot commit];
//    
//    return [self initWithPersistentRoot: aRoot];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: COPersistentRootDidChangeNotification
                                                  object: _persistentRoot];

}

- (void)makeWindowControllers
{
    EWTypewriterWindowController *windowController = [[EWTypewriterWindowController alloc] initWithWindowNibName: [self windowNibName]];
    [self addWindowController: windowController];
}

- (NSString *)windowNibName
{
    return @"EWDocument";
}

- (void)windowControllerDidLoadNib: (NSWindowController *)aController
{
    [super windowControllerDidLoadNib: aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}


- (NSData *)dataOfType: (NSString *)typeName error: (NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    NSException *exception = [NSException exceptionWithName: @"UnimplementedMethod"
                                                     reason: [NSString stringWithFormat: @"%@ is unimplemented",
                                                                                         NSStringFromSelector(
                                                                                             _cmd)]
                                                   userInfo: nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromData: (NSData *)data ofType: (NSString *)typeName error: (NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    NSException *exception = [NSException exceptionWithName: @"UnimplementedMethod"
                                                     reason: [NSString stringWithFormat: @"%@ is unimplemented",
                                                                                         NSStringFromSelector(
                                                                                             _cmd)]
                                                   userInfo: nil];
    @throw exception;
    return YES;
}

- (void)saveDocument: (id)sender
{
    [_persistentRoot editingBranch].shouldMakeEmptyCommit = YES;

    // Since we don't push it on an undo track, the user can't undo "saving"
    [_persistentRoot commitWithType: @"userInvokedSave" shortDescription: @"Save"];
}

- (IBAction) branch: (id)sender
{
    COBranch *branch = [[_persistentRoot editingBranch] makeBranchWithLabel: @"Untitled"];
    [_persistentRoot setCurrentBranch: branch];
    [self commit];
}

- (IBAction) showBranches: (id)sender
{
    [[EWBranchesWindowController sharedController] show];
}

- (IBAction) history: (id)sender
{
    [[EWHistoryWindowController sharedController] show];
}

- (IBAction) pickboard: (id)sender
{
    [[EWPickboardWindowController sharedController] show];
}

- (void)recordUpdatedItems: (NSArray *)items
{
    NSLog(@"Object graph before : %@", [[_persistentRoot editingBranch] objectGraphContext]);

    assert(![_persistentRoot hasChanges]);

    [[[_persistentRoot editingBranch] objectGraphContext] insertOrUpdateItems: items];

    assert([_persistentRoot hasChanges]);

    [self commit];

    assert(![_persistentRoot hasChanges]);

    NSLog(@"Object graph after: %@", [[_persistentRoot editingBranch] objectGraphContext]);
}

- (void)validateCanLoadStateToken: (CORevisionID *)aToken
{
//    COBranch *editingBranchObject = [_persistentRoot branchForUUID: [self editingBranch]];
//    if (editingBranchObject == nil)
//    {
//        [NSException raise: NSInternalInconsistencyException
//                    format: @"editing branch %@ must be one of the persistent root's branches", editingBranch_];
//    }
//    
//    if (![[editingBranchObject allCommits] containsObject: aToken])
//    {
//        [NSException raise: NSInternalInconsistencyException
//                    format: @"the given token %@ must be in the current editing branch's list of states", aToken];
//    }
}

- (void)persistentSwitchToStateToken: (CORevisionID *)aToken
{
    [[_persistentRoot editingBranch] setCurrentRevision: [[_persistentRoot editingContext] revisionForRevisionID: aToken]];
    [self commit];
}

// Doesn't write to DB...
- (void)loadStateToken: (CORevisionID *)aToken
{
    [self validateCanLoadStateToken: aToken];

//    COBranch *editingBranchObject = [_persistentRoot editingBranch];
//    CORevision *rev = [CORevision revisionWithStore: [self store]
//                                         revisionID: aToken];

    //[editingBranchObject setCurrentRevision: rev];

    NSArray *wcs = [self windowControllers];
    for (EWTypewriterWindowController *wc in wcs)
    {
        [wc displayRevision: aToken];
        [wc synchronizeWindowTitleWithDocumentName];
    }
}

- (void)setPersistentRoot: (COPersistentRoot *)aMetadata
{
    assert(aMetadata != nil);

    _persistentRoot = aMetadata;
    [self loadStateToken: [[[_persistentRoot currentBranch] currentRevision] revisionID]];
}

- (NSString *)displayName
{
    return _title;
//    NSString *branchName = [[_persistentRoot currentBranch] label];
//    
//    // FIXME: Get proper persistent root name
//    return [NSString stringWithFormat: @"Untitled (on branch '%@')",
//            branchName];
}

- (void)reloadFromStore
{
    // Reads the UUID of _persistentRoot, and uses that to reload the rest of the metadata

    ETUUID *uuid = [self UUID];

    //[self setPersistentRoot: [store_ persistentRootWithUUID: uuid]];
}

- (ETUUID *)editingBranch
{
    return [[_persistentRoot editingBranch] UUID];
}

- (COPersistentRoot *)currentPersistentRoot
{
    return _persistentRoot;
}

- (ETUUID *)UUID
{
    return [_persistentRoot UUID];
}

- (COSQLiteStore *)store
{
    return [_persistentRoot store];
}

- (void)storePersistentRootMetadataDidChange: (NSNotification *)notif
{
    NSLog(@"did change: %@", notif);

    [self loadStateToken: [[[_persistentRoot currentBranch] currentRevision] revisionID]];
}

- (void)switchToBranch: (ETUUID *)aBranchUUID
{
    COBranch *branch = [_persistentRoot branchForUUID: aBranchUUID];
    [_persistentRoot setCurrentBranch: branch];
    [self commit];
}

- (void)deleteBranch: (ETUUID *)aBranchUUID
{
    [_persistentRoot branchForUUID: aBranchUUID].deleted = YES;
    [self commit];
}

- (COUndoTrack *)undoStack
{
    NSString *name = [NSString stringWithFormat: @"typewriter-%@-%@",
                                                 [_persistentRoot UUID],
                                                 _title];

    return [COUndoTrack trackForName: name
                  withEditingContext: [_persistentRoot editingContext]];;
}

- (void)commit
{
    [[_persistentRoot editingContext] commitWithUndoTrack: [self undoStack]];
}

+ (void)pullFrom: (COPersistentRoot *)source into: (COPersistentRoot *)dest
{
    COSynchronizationClient *client = [[COSynchronizationClient alloc] init];
    COSynchronizationServer *server = [[COSynchronizationServer alloc] init];

    id request2 = [client updateRequestForPersistentRoot: [dest UUID]
                                                serverID: @"server"
                                                   store: [dest store]];
    id response2 = [server handleUpdateRequest: request2 store: [source store]];
    [client handleUpdateResponse: response2 store: [dest store]];

    // Now merge "origin/master" into "master"

    COPersistentRootInfo *info = [[dest store] persistentRootInfoForUUID: [dest UUID]];

    ETUUID *uuid = [[[info branchInfosWithMetadataValue: [[[source currentBranch] UUID] stringValue]
                                                 forKey: @"replcatedBranch"] firstObject] UUID];

    COBranch *master = [dest currentBranch];
    COBranch *originMaster = [dest branchForUUID: uuid];
    assert(master != nil);
    assert([info branchInfoForUUID: uuid] != nil);
    assert(originMaster != nil);
    assert(![master isEqual: originMaster]);

    // FF merge?

    if ([COLeastCommonAncestor isRevision: [[master currentRevision] revisionID]
                equalToOrParentOfRevision: [[originMaster currentRevision] revisionID]
                                    store: [dest store]])
    {
        [master setCurrentRevision: [originMaster currentRevision]];
        [dest commit];
    }
    else
    {
        // Regular merge

        [master setMergingBranch: originMaster];

        COMergeInfo *mergeInfo = [master mergeInfoForMergingBranch: originMaster];
        if ([mergeInfo.diff hasConflicts])
        {
            NSLog(@"Attempting to auto-resolve conflicts favouring the other user...");
            [mergeInfo.diff resolveConflictsFavoringSourceIdentifier: @"merged"]; // FIXME: Hardcoded
        }

        [mergeInfo.diff applyTo: [master objectGraphContext]];

        // HACK: should be a regular -commit, I guess, but there's a bug where
        // -commit uses the last used undo track, instead of none. So explicitly pass nil,
        // so this commit doesn't record an undo command.
        [[dest editingContext] commitWithUndoTrack: nil];
    }
}

- (IBAction) push: (id)sender
{
    NSLog(@"FIXME: Not implemented");
}

- (IBAction) pull1: (id)sender
{
    [EWDocument pullFrom: [(EWAppDelegate *)[NSApp delegate] user1PersistentRoot]
                    into: _persistentRoot];
}

- (IBAction) pull2: (id)sender
{
    [EWDocument pullFrom: [(EWAppDelegate *)[NSApp delegate] user2PersistentRoot]
                    into: _persistentRoot];
}

- (IBAction) pull3: (id)sender
{
    [EWDocument pullFrom: [(EWAppDelegate *)[NSApp delegate] user3PersistentRoot]
                    into: _persistentRoot];
}

/* EWUndoManagerDelegate */

- (void)undo
{
    [[self undoStack] undo];
}

- (void)redo
{
    [[self undoStack] redo];
}

- (BOOL)canUndo
{
    return [[self undoStack] canUndo];
}

- (BOOL)canRedo
{
    return [[self undoStack] canRedo];
}

- (NSString *)undoMenuItemTitle
{
    return @"Undo";
}

- (NSString *)redoMenuItemTitle
{
    return @"Redo";
}

// Misc

- (COPersistentRoot *)persistentRoot
{
    return _persistentRoot;
}

@end
