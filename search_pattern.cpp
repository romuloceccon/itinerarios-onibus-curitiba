#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <iostream>

using namespace cv;
using namespace std;

int main(int argc, char** argv)
{
  Mat pattern, src;
  vector<Vec2i> test_points;
  Vec2i p;
  
  if (argc < 3)
    exit(1);
  
  pattern = imread(argv[1], 0);
  src = imread(argv[2], 0);
  
  for (int i = 0; i < pattern.rows; i++)
  {
    for (int j = 0; j < pattern.cols; j++)
    {
      uchar a = pattern.at<uchar>(i, j);
      if (a > 128)
      {
        p[0] = i;
        p[1] = j;
        test_points.push_back(p);
      } 
    }
  }
  
  int score_threshold = test_points.size() * 1.0;
  
  for (int i = 0; i < src.rows - pattern.rows + 1; i++)
  {
    for (int j = 0; j < src.cols - pattern.cols + 1; j++)
    {
      int score = 0;
      for (vector<Vec2i>::iterator p = test_points.begin(); p != test_points.end(); p++)
      {
        uchar a = src.at<uchar>(i + (*p)[0], j + (*p)[1]);
        if (a > 128)
          score++;
      }
      if (score >= score_threshold)
        cout << j << "," << i << " (" << score << ")" << endl;
    }
  }  
  
  return 0;
}
