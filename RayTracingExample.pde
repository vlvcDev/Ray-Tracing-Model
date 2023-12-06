// Processing program for ray tracing with animated rays

int detail = 4; // Lower detail value = higher detail, but worse performance
int raySpeed = 3; // Speed of ray animation
ArrayList<Ray> rays;
Sphere sphere;
PVector camera;

void setup() {
  // We can initialize the size of the program window, which in essence is a matrix of 800 by 600 pixels.
  // We are also telling the program to create a 3d space so that we can simulate 3d space on the computer.
  size(1920, 1080, P3D);
  noStroke();
  
  // The camera is our point of view, and we're setting it to the middle of width and height of the 3d space.
  // We are also moving the camera back along the third axis so that we can view the whole scene from a distance.
  camera = new PVector(width / 2, height / 2, -500);
  // We create a sphere and place it in the middle of the scene, and give it a radius of 50
  sphere = new Sphere(new PVector(width / 2, height / 2, 0), 50);
  rays = new ArrayList<Ray>();

  // Here, we initialize the rays, with their starting point being in the center of the viewpoint,
  // and their amount being the amount of pixels / detail for performance and detail reasons.
  // More rays will result in a more detailed image, but with a much longer runtime.
  for (int x = 0; x < width; x += detail) {
    for (int y = 0; y < height; y += detail) {
      PVector target = new PVector(x, y, 0);
      rays.add(new Ray(camera, target));
    }
  }
}

void draw() {
  background(250);
  // In each frame, update and display each ray in the 'rays' array.
  for (Ray ray : rays) {
    ray.update();
    ray.display();
  }
}

class Ray {
  PVector origin; // The starting point of the ray.
  PVector target; // The target point where the ray is directed.
  PVector position; // The current position of the ray.
  PVector direction; // The direction vector of the ray.
  boolean reachedTarget = false; // Flag to check if the ray has reached its target.

  Ray(PVector origin, PVector target) {
    this.origin = origin;
    this.target = target;
    this.position = origin.copy();
    // Calculates the direction vector by subtracting the origin from the target and normalizing it.
    // Direction = (Target - Origin) / ||Target - Origin||
    this.direction = PVector.sub(target, origin).normalize();
  }

  void update() {
    // Moves the ray towards its target at a fixed speed. Stops the ray if it's close to the target.
    if (!reachedTarget) {
      position.add(PVector.mult(direction, raySpeed));
      if (PVector.dist(position, target) < raySpeed) {
        reachedTarget = true;
      }
    }
  }

  void display() {
    // Displays the ray. If it has reached the target, it checks for intersection with the sphere.
    // Colors the target point based on whether there's an intersection (red) or not (green).
    // If the ray is still moving, it is displayed as a blue point.
    if (reachedTarget) {
      if (intersectsSphere(sphere)) {
        fill(255, 0, 0);
      } else {
        fill(0, 255, 0);
      }
      rect(target.x, target.y, detail, detail);
    } else {
      stroke(0, 0, 255);
      point(position.x, position.y, position.z);
    }
  }

  boolean intersectsSphere(Sphere sphere) {
    // Calculates if the ray intersects the sphere using the ray-sphere intersection formula.
    // oc = Origin - Center of Sphere
    PVector oc = PVector.sub(origin, sphere.center);
    // Quadratic term: a = dot(Direction, Direction)
    float a = direction.dot(direction);
    // Linear term: b = 2 * dot(OC, Direction)
    float b = 2.0 * oc.dot(direction);
    // Constant term: c = dot(OC, OC) - Radius^2
    float c = oc.dot(oc) - sphere.radius * sphere.radius;
    // Discriminant = b^2 - 4ac. If Discriminant > 0, there's an intersection.
    float discriminant = b * b - 4 * a * c;
    return discriminant > 0;
  }
}

class Sphere {
  PVector center; // The center of the sphere in 3D space.
  float radius; // The radius of the sphere.

  Sphere(PVector center, float radius) {
    this.center = center;
    this.radius = radius;
  }
}
