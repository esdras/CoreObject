#import "ProjectNavWindowController.h"
#import "PRoject.h"

@implementation ProjectNavWindowController

- (id)init
{
	self = [super initWithWindowNibName: @"ProjectNav"];
	
	if (self) {
	}
	return self;
}

- (NSArray *) projectsSorted
{
	NSArray *unsorted = [[[NSApp delegate] projects] allObjects];
	
	return [unsorted sortedArrayUsingDescriptors:
	 @[[[NSSortDescriptor alloc] initWithKey:@"name" ascending: YES]]];
}

- (void)awakeFromNib
{
	// Hmm.. we really need to listen for persistent root creation
	// and update our outline view.
	
}

/* NSOutlineView data source */

- (id) outlineView: (NSOutlineView *)outlineView child: (NSInteger)index ofItem: (id)item
{
	if (nil == item) {
		return [[self projectsSorted] objectAtIndex: index];
	}
	
	Project *project = item;
	
	return [[item documentsSorted] objectAtIndex: index];
}

- (BOOL) outlineView: (NSOutlineView *)outlineView isItemExpandable: (id)item
{
	return [self outlineView: outlineView numberOfChildrenOfItem: item] > 0;
}

- (NSInteger) outlineView: (NSOutlineView *)outlineView numberOfChildrenOfItem: (id)item
{
	if (nil == item) {
		return [[self projectsSorted] count];
	}
	
	if ([item isKindOfClass: [Project class]])
	{
		return [[item documents] count];
	}
	
	return 0;
}

- (id) outlineView: (NSOutlineView *)outlineView objectValueForTableColumn: (NSTableColumn *)column byItem: (id)item
{
	if (nil == item) { return nil; }
	
	return [item valueForProperty: @"name"];
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
//	if (nil == item) { item = [self rootObject]; }
//	
//	if ([item isKindOfClass: [OutlineItem class]])
//	{
//		NSString *oldLabel = [[item label] retain];
//		[item setLabel: object];
//		
//		[self commitWithType: @"kCOTypeMinorEdit"
//			shortDescription: @"Edit Label"
//			 longDescription: [NSString stringWithFormat: @"Edit label from %@ to %@", oldLabel, [item label]]];
//		
//		[oldLabel release];
//	}
}

@end