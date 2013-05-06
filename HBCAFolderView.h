#import <Velox/VeloxFolderViewProtocol.h>

@interface HBCAFolderView : UIView <VeloxFolderViewProtocol, UITableViewDataSource, UITableViewDelegate> {
	UITableView *_tableView;
	NSArray *_toDos;
	float _cellHeight;
}
@end
