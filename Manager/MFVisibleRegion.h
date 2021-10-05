#import <CoreLocation/CoreLocation.h>

/**
 * GMSVisibleRegion contains the four points defining the polygon that is visible in a map's camera.
 *
 * This polygon can be a trapezoid instead of a rectangle, because a camera can have tilt. If the
 * camera is directly over the center of the camera, the shape is rectangular, but if the camera is
 * tilted, the shape will appear to be a trapezoid whose smallest side is closest to the point of
 * view.
 */
typedef struct {

  /** Bottom left corner of the camera. */
  CLLocationCoordinate2D nearLeft;

  /** Bottom right corner of the camera. */
  CLLocationCoordinate2D nearRight;

  /** Far left corner of the camera. */
  CLLocationCoordinate2D farLeft;

  /** Far right corner of the camera. */
  CLLocationCoordinate2D farRight;
} MFVisibleRegion;
