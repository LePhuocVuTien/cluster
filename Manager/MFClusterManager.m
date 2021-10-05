/* Copyright (c) 2016 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//#import "GMUClusterManager+Testing.h"

#import "MFClusterManager.h"
#import "GMUSimpleClusterAlgorithm.h"

static NSString *const kGMUCameraKeyPath = @"camera";

// How long to wait for a cluster request before actually performing the clustering operation
// to avoid continuous clustering when the camera is moving which can affect performance.
static const double kGMUClusterWaitIntervalSeconds = 0.2;

@implementation MFClusterManager {
  // The map view that this object is associated with.
  MFMapView *_mapView;

  // Position of the camera on the previous cluster invocation.
  MFCameraPosition *_previousCamera;

  // Tracks number of cluster requests so that we can safely ignore stale (redundant) ones.
  NSUInteger _clusterRequestCount;

  // Renderer.
  id<GMUClusterRenderer> _renderer;
}

- (instancetype)initWithMap:(MFMapView *)mapView
                  algorithm:(id<GMUClusterAlgorithm>)algorithm
                   renderer:(id<GMUClusterRenderer>)renderer {
  if ((self = [super init])) {
    _algorithm = [[GMUSimpleClusterAlgorithm alloc] init];
    _mapView = mapView;
    _previousCamera = _mapView.camera;
    _algorithm = algorithm;
    _renderer = renderer;

    //[_mapView addObserver:self forKeyPath:kGMUCameraKeyPath options:NSKeyValueObservingOptionNew context:nil];
  }

  return self;
}


- (void)dealloc {
  [_mapView removeObserver:self forKeyPath:kGMUCameraKeyPath];
}

- (void) setMapDelegate:(id<MFMapViewDelegate> _Nullable)mapDelegate {
  _mapView.delegate = self;
  _mapDelegate = mapDelegate;
}

- (void)setDelegate:(id<GMUClusterManagerDelegate>)delegate
        mapDelegate:(id<MFMapViewDelegate> _Nullable)mapDelegate {
  _delegate = delegate;
  _mapView.delegate = self;
  _mapDelegate = mapDelegate;
}

- (void)addItem:(id<GMUClusterItem>)item {
  [_algorithm addItems:[[NSMutableArray alloc] initWithObjects:item, nil]];
}

- (void)addItems:(NSArray<id<GMUClusterItem>> *)items {
  [_algorithm addItems:items];
}

- (void)removeItem:(id<GMUClusterItem>)item {
  [_algorithm removeItem:item];
}

- (void)clearItems {
  [_algorithm clearItems];
  [self requestCluster];
}

- (void)cluster {
  NSUInteger integralZoom = (NSUInteger)floorf(_mapView.camera.zoom + 0.5f);
  NSArray<id<GMUCluster>> *clusters = [_algorithm clustersAtZoom:integralZoom];
  [_renderer renderClusters:clusters];
  _previousCamera = _mapView.camera;
}

#pragma mark MFMapViewDelegate

- (BOOL)mapview:(MFMapView *)mapView didTapMarker:(MFMarker *)marker {
  if ([_delegate respondsToSelector:@selector(clusterManager:didTapCluster:)] &&
      [marker.userData conformsToProtocol:@protocol(GMUCluster)]) {
    id<GMUCluster> cluster = marker.userData;
    if ([_delegate clusterManager:self didTapCluster:cluster]) {
      return YES;
    }
  }

  if ([_delegate respondsToSelector:@selector(clusterManager:didTapClusterItem:)] &&
      [marker.userData conformsToProtocol:@protocol(GMUClusterItem)]) {
    id<GMUClusterItem> clusterItem = marker.userData;
    if ([_delegate clusterManager:self didTapClusterItem:clusterItem]) {
      return YES;
    }
  }

  // Forward to _mapDelegate as a fallback.
  if ([_mapDelegate respondsToSelector:@selector(mapview:didTapMarker:)]) {
    return [_mapDelegate mapview:mapView didTapMarker:marker];
  }

  return NO;
}

#pragma mark Delegate Forwards

- (void)mapView:(MFMapView *)mapView willMove:(BOOL)gesture {
  if ([_mapDelegate respondsToSelector:@selector(mapView:willMove:)]) {
    [_mapDelegate mapView:mapView willMove:gesture];
  }
}

- (void)mapView:(MFMapView *)mapView didChangeCameraPosition:(MFCameraPosition *)position {
  if ([_mapDelegate respondsToSelector:@selector(mapView:didChangeCameraPosition:)]) {
    [_mapDelegate mapView:mapView didChangeCameraPosition:position];
  }
}

- (void)mapView:(MFMapView *)mapView idleAtCameraPosition:(MFCameraPosition *)position {
  if ([_mapDelegate respondsToSelector:@selector(mapView:idleAtCameraPosition:)]) {
    [_mapDelegate mapView:mapView idleAtCameraPosition:position];
  }
  [self requestCluster];
}

- (void)mapView:(MFMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
  if ([_mapDelegate respondsToSelector:@selector(mapView:didTapAtCoordinate:)]) {
    [_mapDelegate mapView:mapView didTapAtCoordinate:coordinate];
  }
}

- (void)mapView:(MFMapView *)mapView didTapInfoWindowOfMarker:(MFMarker *)marker {
  if ([_mapDelegate respondsToSelector:@selector(mapView:didTapInfoWindowOfMarker:)]) {
    [_mapDelegate mapview:mapView didTapInfoWindowOfMarker:marker];
  }
}

- (UIView *)mapView:(MFMapView *)mapView markerInfoWindow:(MFMarker *)marker {
  if ([_mapDelegate respondsToSelector:@selector(mapView:markerInfoWindow:)]) {
    return [_mapDelegate mapView:mapView markerInfoWindow:marker];
  }
  return nil;
}

- (void)mapView:(MFMapView *)mapView
    didTapPOIWithPlaceID:(NSString *)placeID
                    name:(NSString *)name
                location:(CLLocationCoordinate2D)location {
  if ([_mapDelegate respondsToSelector:@selector(mapView:didTapPOIWithPlaceID:name:location:)]) {
    [_mapDelegate mapView:mapView didTapPOIWithPlaceID:placeID name:name location:location];
  }
}

- (UIView *)mapView:(MFMapView *)mapView markerInfoContents:(MFMarker *)marker {
  if ([_mapDelegate respondsToSelector:@selector(mapView:markerInfoContents:)]) {
    return [_mapDelegate mapView:mapView markerInfoWindow:marker];
    
  }
  return nil;
}

- (void)mapView:(MFMapView *)mapView didBeginDraggingMarker:(MFMarker *)marker {
  if ([_mapDelegate respondsToSelector:@selector(mapView:didBeginDraggingMarker:)]) {
    [_mapDelegate mapview:mapView didBeginDraggingMarker:marker];
  }
}

- (void)mapView:(MFMapView *)mapView didEndDraggingMarker:(MFMarker *)marker {
  if ([_mapDelegate respondsToSelector:@selector(mapView:didEndDraggingMarker:)]) {
    [_mapDelegate mapview:mapView didEndDraggingMarker:marker];
  }
}

- (void)mapView:(MFMapView *)mapView didDragMarker:(MFMarker *)marker {
  if ([_mapDelegate respondsToSelector:@selector(mapView:didDragMarker:)]) {
    [_mapDelegate mapview:mapView didDragMarker:marker];
  }
}

- (BOOL)didTapMyLocationButtonForMapView:(MFMapView *)mapView {
  if ([_mapDelegate respondsToSelector:@selector(didTapMyLocationButtonForMapView:)]) {
    return [_mapDelegate didTapMyLocationButtonForMapView:mapView];
  }
  return NO;
}

#pragma mark Testing

- (NSUInteger)clusterRequestCount {
  return _clusterRequestCount;
}

#pragma mark Private

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *, id> *)change
                       context:(void *)context {
  MFCameraPosition *camera = _mapView.camera;
  NSUInteger previousIntegralZoom = (NSUInteger)floorf(_previousCamera.zoom + 0.5f);
  NSUInteger currentIntegralZoom = (NSUInteger)floorf(camera.zoom + 0.5f);
  if (previousIntegralZoom != currentIntegralZoom) {
    [self requestCluster];
  } else {
    [_renderer update];
  }
}

- (void)requestCluster {
  __weak MFClusterManager *weakSelf = self;
  ++_clusterRequestCount;
  NSUInteger requestNumber = _clusterRequestCount;
  dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kGMUClusterWaitIntervalSeconds * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{
        MFClusterManager *strongSelf = weakSelf;
        if (strongSelf == nil) {
          return;
        }

        // Ignore if there are newer requests.
        if (requestNumber != strongSelf->_clusterRequestCount) {
          return;
        }
        [strongSelf cluster];
      });
}

@end
