#import "HBCAFolderView.h"
#import <SpringBoard/SBApplicationController.h>

#define kHBCAFont [UIFont boldSystemFontOfSize:16.f]
#define kHBCATextFieldFont [UIFont systemFontOfSize:16.f]
#define kHBCANoToDosText @"No To-Dos" // this feels dirty, but carrot only supports english anyway so...
#define kHBCAPullToAddText @"Pull down to add item"
#define kHBCAReleaseToAddText @"Release!"

@implementation HBCAFolderView
+ (int)folderHeight {
	return 250;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		_cellHeight = [@"X" sizeWithFont:kHBCAFont].height + 20.f;

		_tableView = [[UITableView alloc] initWithFrame:frame];
		_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_tableView.dataSource = self;
		_tableView.delegate = self;
		_tableView.backgroundView = [[[UIView alloc] init] autorelease];
		_tableView.backgroundColor = [UIColor clearColor];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		[self addSubview:_tableView];

		_textField = [[UITextField alloc] initWithFrame:CGRectMake(10.f, -_cellHeight, frame.size.width - 20.f, _cellHeight)];
		_textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_textField.delegate = self;
		_textField.font = kHBCATextFieldFont;
		_textField.placeholder = kHBCAPullToAddText;
		_textField.textColor = [UIColor whiteColor];
		_textField.returnKeyType = UIReturnKeyDone;
		_textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		[_tableView addSubview:_textField];

		NSArray *items = [[NSDictionary dictionaryWithContentsOfFile:[[[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:@"com.grailr.CARROT"].sandboxPath stringByAppendingString:@"/Documents/todo.archive"]] objectForKey:@"$objects"];
		NSMutableArray *newToDos = [NSMutableArray array];

		for (id item in items) {
			if ([item isKindOfClass:NSString.class] && ![item isEqualToString:@"$null"] && ![item isEqualToString:@"Daily"] && ![item isEqualToString:@"Weekly"] && ![item isEqualToString:@"Monthly"]) {
				[newToDos addObject:item];
			}
		}

		_toDos = [newToDos copy];

		[_tableView reloadData];
	}

	return self;
}

- (float)realHeight {
	return _tableView.contentSize.height;
}

- (void)viewTapped:(UITapGestureRecognizer *)gestureRecogniser {
	[_textField resignFirstResponder];
	_textField.text = @"";

	[self removeGestureRecognizer:gestureRecogniser];

	[UIView animateWithDuration:0.3f animations: ^{
		_tableView.contentInset = UIEdgeInsetsZero;
	}];

	_isShowingTextField = NO;
}

- (void)dealloc {
	[_tableView release];
	[_toDos release];
	[super dealloc];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _toDos.count ?: 1;
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

	if (_toDos.count) {
		cell.textLabel.text = [_toDos objectAtIndex:indexPath.row];
	} else {
		cell.textLabel.text = kHBCANoToDosText;
		cell.textLabel.textAlignment = UITextAlignmentCenter;
	}

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return _cellHeight;
}

#pragma mark - UITextFieldDelegate

#pragma mark - UIScrollViewDelegate

// based on https://github.com/leah/PullToRefresh/blob/master/Classes/PullRefreshTableViewController.m

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	if (_isShowingTextField) {
		return;
	}

	_isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (_isShowingTextField) {
		if (_tableView.contentOffset.y > 0) {
			_tableView.contentInset = UIEdgeInsetsZero;
		} else if (_tableView.contentOffset.y >= -_cellHeight) {
			_tableView.contentInset = UIEdgeInsetsMake(-_tableView.contentOffset.y, 0, 0, 0);
		}
	} else if (_isDragging && _tableView.contentOffset.y < 0) {
		_textField.placeholder = _tableView.contentOffset.y < -_cellHeight ? kHBCAReleaseToAddText : kHBCAPullToAddText;
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (_isShowingTextField) {
		return;
	}

	_isDragging = NO;

	if (_tableView.contentOffset.y <= -_cellHeight) {
		_isShowingTextField = YES;

		[_textField becomeFirstResponder];
		_textField.placeholder = @"";

		UITapGestureRecognizer *gestureRecogniser = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)] autorelease];
		[self addGestureRecognizer:gestureRecogniser];

		[UIView animateWithDuration:0.3f animations:^{
			_tableView.contentInset = UIEdgeInsetsMake(_cellHeight, 0, 0, 0);
		}];
	}
}

@end
