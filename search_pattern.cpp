#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <iostream>
#include <stdio.h>

using namespace cv;
using namespace std;

#define DEBUG_PATTERN 0

bool black(int a)
{
  return a < 16;
}

bool white(int a)
{
  return a >= 240;
}

int main(int argc, char** argv)
{
  if (argc < 4)
  {
    cerr << "Usage: search_pattern <pattern.png> <threshold> <source.png>" << endl;
    exit(1);
  }
  
  Mat pattern = imread(argv[1], 0);
  if (pattern.empty())
  {
    cerr << "Bad pattern file" << endl;
    exit(1);
  }
  
  char *p;
  double perc_threshold = strtol(argv[2], &p, 10) / 100.0;
  
  Mat src = imread(argv[3], 0);
  if (src.empty())
  {
    cerr << "Bad source file" << endl;
    exit(1);
  }
  
  int offset_i, offset_j;
  offset_i = pattern.rows / 2;
  offset_j = pattern.cols / 2;
  
  int test_points = 0;
  
  for (int i = 0; i < pattern.rows; i++)
  {
    for (int j = 0; j < pattern.cols; j++)
    {
      uchar a = pattern.at<uchar>(i, j);
      if (black(a) || white(a))
        test_points++;
      
#     if DEBUG_PATTERN
        printf("%3d ", (int) a);
#     endif
    }
    
#   if DEBUG_PATTERN
      printf("\n");
#   endif
  }
  
  if (test_points < 20)
  {
    cerr << "Something is wrong. " << test_points << " test point(s) were found in the pattern." << endl;
    exit(1);
  }
  
  int score_threshold = test_points * perc_threshold;
  cerr << "max_score=" << test_points << endl;
  cerr << "threshold=" << score_threshold << endl;
  
  Mat test_area;
  Mat element = getStructuringElement(MORPH_ELLIPSE, Size(20, 20));
  dilate(src, test_area, element);  
  
  int max_i = src.rows - pattern.rows + offset_i + 1;
  int max_j = src.cols - pattern.cols + offset_j + 1;
  
#if 0  
  for (int p_i = 0; p_i < pattern.rows; p_i++)
  {
    for (int p_j = 0; p_j < pattern.cols; p_j++)
    {
      uchar p_v = pattern.at<uchar>(p_i, p_j);
      if (black(p_v))
        cout << "-";
      else if (white(p_v))
        cout << "*";
      else
        cout << " ";
    }
    cout << endl;
  }
#endif

#if 0
  int test_i = 1849;
  int test_j = 75;

  cout << "=====================================" << endl;
  
  for (int p_i = 0; p_i < pattern.rows; p_i++)
  {
    for (int p_j = 0; p_j < pattern.cols; p_j++)
    {
      uchar v = src.at<uchar>(test_i - offset_i + p_i, test_j - offset_j + p_j);
      if (black(v))
        cout << "-";
      else if (white(v))
        cout << "*";
      else
        cout << " ";
    }
    cout << endl;
  }
#endif

  int test_count = 0;
  int objects_found = 0;
  
  for (int i = offset_i; i < max_i; i++)
  {
    for (int j = offset_j; j < max_j; j++)
    {
      uchar a = test_area.at<uchar>(i, j);
      
      if (!white(a))
        continue;
      
      test_count++;
      
      int score = 0;
      for (int p_i = 0; p_i < pattern.rows; p_i++)
      {
        for (int p_j = 0; p_j < pattern.cols; p_j++)
        {
          uchar v = src.at<uchar>(i - offset_i + p_i, j - offset_j + p_j);
          uchar p_v = pattern.at<uchar>(p_i, p_j);
          
          if (black(p_v) && black(v) || white(p_v) && white(v))
            score++;
        }
      }
      
      if (score >= score_threshold)
      {
        objects_found++;
        cout << j << "," << i << " (" << score << ")" << endl;
      }
    }
  }

  cerr << "objects_found=" << objects_found << endl;
  cerr << "test_count=" << test_count << endl; 

  return 0;
}
