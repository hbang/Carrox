#import "HBCAFolderView.h"
#import <SpringBoard/SBApplicationController.h>

#define kHBCAFont [UIFont boldSystemFontOfSize:16.f]

@implementation HBCAFolderView
+ (int)folderHeight {
	return 250;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

    if (self) {
		_tableView = [[UITableView alloc] initWithFrame:frame];
		_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_tableView.dataSource = self;
		_tableView.delegate = self;
		_tableView.backgroundView = [[[UIView alloc] init] autorelease];
		_tableView.backgroundColor = [UIColor clearColor];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		[self addSubview:_tableView];

		NSArray *items = [[NSDictionary dictionaryWithContentsOfFile:[[[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:@"com.grailr.CARROT"].sandboxPath stringByAppendingString:@"/Documents/todo.archive"]] objectForKey:@"$objects"];
		NSMutableArray *newToDos = [NSMutableArray array];

		for (id item in items) {
			if ([item isKindOfClass:NSString.class] && ![item isEqualToString:@"$null"] && ![item isEqualToString:@"Daily"] && ![item isEqualToString:@"Weekly"] && ![item isEqualToString:@"Monthly"]) {
				[newToDos addObject:item];
			}
		}

		_toDos = [newToDos copy];

		_cellHeight = [@"X" sizeWithFont:kHBCAFont].height + 20.f;
	}

    return self;
}

- (float)realHeight {
	return _cellHeight * _toDos.count;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _toDos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"CarroxCell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.textColor = [UIColor whiteColor];
		cell.textLabel.font = kHBCAFont;
		cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	cell.textLabel.text = [_toDos objectAtIndex:indexPath.row];

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return _cellHeight;
}

@end
