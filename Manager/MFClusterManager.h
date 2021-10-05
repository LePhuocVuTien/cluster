//
//  ClusterManager.h
//  ObjCDemoApp
//
//  Created by iMacbook on 10/5/21.
//  Copyright © 2021 Google. All rights reserved.
//

#import <Map4dMap/Map4dMap.h>

#import "GMUClusterAlgorithm.h"
#import "GMUClusterItem.h"
#import "GMUClusterRenderer.h"
#import "MFDefaultClusterRenderer.h"

NS_ASSUME_NONNULL_BEGIN
@class MFClusterManager;

@protocol GMUClusterManagerDelegate <NSObject>

@optional

/**
* Called when the user taps on a cluster marker.
* @return YES if this delegate handled the tap event,
* and NO to pass this tap event to other handlers.
*/
- (BOOL)clusterManager:(MFClusterManager *)clusterManager didTapCluster:(id<GMUCluster>)cluster;

/**
* Called when the user taps on a cluster item marker.
* @return YES if this delegate handled the tap event,
* and NO to pass this tap event to other handlers.
*/
- (BOOL)clusterManager:(MFClusterManager *)clusterManager
    didTapClusterItem:(id<GMUClusterItem>)clusterItem;

@end

@interface MFClusterManager : NSObject <MFMapViewDelegate>

/**
 * The default initializer is not available. Use initWithMap:algorithm:renderer instead.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Returns a new instance of the GMUClusterManager class defined by it's |algorithm| and |renderer|.
 */
- (instancetype)initWithMap:(MFMapView *)mapView
                  algorithm:(id<GMUClusterAlgorithm>)algorithm
                   renderer:(id<GMUClusterRenderer>)renderer NS_DESIGNATED_INITIALIZER;

/**
 * Returns the clustering algorithm.
 */
@property(nonatomic, readonly) id<GMUClusterAlgorithm> algorithm;

/**
 * GMUClusterManager |delegate|.
 * To set it use the setDelegate:mapDelegate: method.
 */
@property(nonatomic, readonly, weak, nullable) id<GMUClusterManagerDelegate> delegate;

/**
 * The MFMapViewDelegate delegate that map events are being forwarded to.
 * To set it use the setDelegate:mapDelegate: method.
 */
@property(nonatomic, readonly, weak, nullable) id<MFMapViewDelegate> mapDelegate;

/**
 * Sets a |mapDelegate| to listen to forwarded map events.
 */
- (void)setMapDelegate:(id<MFMapViewDelegate> _Nullable)mapDelegate;

/**
 * Sets GMUClusterManagerDelegate |delegate| and optionally
 * provides a |mapDelegate| to listen to forwarded map events.
 *
 * NOTES: This method changes the |delegate| property of the
 * managed |mapView| to this object, intercepting events that
 * the GMUClusterManager wants to action or rebroadcast
 * to the GMUClusterManagerDelegate. Any remaining events are
 * then forwarded to the new |mapDelegate| provided here.
 *
 * EXAMPLE: [clusterManager setDelegate:self mapDelegate:_map.delegate];
 * In this example self will receive type-safe GMUClusterManagerDelegate
 * events and other map events will be forwarded to the current map delegate.
 */
- (void)setDelegate:(id<GMUClusterManagerDelegate> _Nullable)delegate
        mapDelegate:(id<MFMapViewDelegate> _Nullable)mapDelegate;

/**
 * Adds a cluster item to the collection.
 */
- (void)addItem:(id<GMUClusterItem>)item;

/**
 * Adds multiple cluster items to the collection.
 */
- (void)addItems:(NSArray<id<GMUClusterItem>> *)items;

/**
 * Removes a cluster item from the collection.
 */
- (void)removeItem:(id<GMUClusterItem>)item;

/**
 * Removes all items from the collection.
 */
- (void)clearItems;

/**
 * Called to arrange items into groups.
 * - This method will be automatically invoked when the map's zoom level changes.
 * - Manually invoke this method when new items have been added to rearrange items.
 */
- (void)cluster;
@end

NS_ASSUME_NONNULL_END
