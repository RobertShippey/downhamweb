//
//  DWNewsViewController.h
//  DownhamWeb
//
//  Created by Robert Shippey on 20/05/2013.
//

#import <UIKit/UIKit.h>

@interface DWNewsViewController : DWTableViewController <UITableViewDataSource, UITableViewDelegate>

@end


@interface DWNewsTableCell : UITableViewCell

@property (nonatomic) IBOutlet UIImageView *articleImage;
@property (nonatomic) IBOutlet UILabel *articleTitle;
@property (nonatomic) IBOutlet UILabel *articleSubtitle;

@end
