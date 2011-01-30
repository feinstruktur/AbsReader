//
//  ArticleCache.h
//  AbsReader
//
//  Created by Sven A. Schmidt on 29.12.10.
//  Copyright 2010 abstracture GmbH & Co. KG. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FeedCacheDelegate;

@interface FeedCache : NSObject<NSXMLParserDelegate> {
}

@property (nonatomic, assign) id<FeedCacheDelegate> delegate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSMutableDictionary *cache;
@property (nonatomic, retain) NSMutableArray *stories;
@property (nonatomic, retain) NSXMLParser *rssParser;
@property (nonatomic, retain) NSMutableDictionary *item;
@property (nonatomic, retain) NSMutableString *currentValue;
@property (nonatomic, retain) NSMutableData *rssData;
@property (assign) BOOL recordCharacters;
@property (nonatomic, retain) NSDate *lastRefresh;
@property (assign) BOOL refreshInProgress;
@property (nonatomic, retain) NSMutableDictionary *readArticles;

- (void)refresh;
- (void)markGuidRead:(NSString *)guid forDate:(NSDate *)date;
- (void)markAllRead;
- (BOOL)alreadyVisited:(NSString *)guid;
- (NSUInteger)unreadCount;

@end

@protocol FeedCacheDelegate<NSObject>

- (void)errorOccurred:(NSError *)error;
- (void)didEndDocument;

@end
