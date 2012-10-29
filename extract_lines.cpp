#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"

#include <iostream>

using namespace cv;
using namespace std;

int main(int argc, char** argv)
{
  if (argc != 2)
  {
    cerr << "error (command line)" << endl;
    return 1;
  }
  
  const char* filename = argv[1];

  Mat src = imread(filename, 0);
  if (src.empty())
  {
    cerr << "error (open" << filename << ")" << endl;
    return 1;
  }

  Mat dst;
  Canny(src, dst, 50, 200, 3);

  vector<Vec4i> lines;
  HoughLinesP(dst, lines, 1, CV_PI / 180, 20, 10, 10);
  for (size_t i = 0; i < lines.size(); i++)
  {
    Vec4i l = lines[i];
    cout << l[0] << "," << l[1] << ";" << l[2] << "," << l[3] << endl;
  }

  return 0;
}
