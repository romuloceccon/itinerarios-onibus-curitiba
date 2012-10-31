#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <iostream>

using namespace cv;
using namespace std;

int main(int argc, char** argv)
{
  Mat src, dst;
  
  if (argc < 3)
    exit(1);
  
  src = imread(argv[1], 0);

  Mat element = getStructuringElement(MORPH_ELLIPSE, Size(20, 20));
  dilate(src, dst, element);
  
  imwrite(argv[2], dst);
  
  return 0;
}
