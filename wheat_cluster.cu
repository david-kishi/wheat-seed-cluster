/******************************************************************************
* FILE: wheat_cluster.cu
* DESCRIPTION:
*   A simple cuda program to compute k-means cluster of a variety of wheat
*   wheat seeds.
* AUTHOR: David Nguyen
* CONTACT: david@knytes.com 
* REVISED: 06/05/2020
******************************************************************************/
#include <cuda.h>
#include <math.h>
#include <stdio.h>

#define NUMOFCLASSES  3
#define NUMOFFEATURES 7
#define MAXCHAR 9300


//TODO Device function for k-means clustering
// Should return the new points of the centroids


int main(){
  //TODO Read in dataset and store into array.
  // 210 total - 70 per class - put 10 random from each class
  FILE *fp;
  char str[MAXCHAR];
  char* filename = "seeds_dataset.txt";

  fp = fopen(filename, "r");
  if (fp == NULL){
      printf("Could not open file %s",filename);
      return 1;
  }
  while (fgets(str, MAXCHAR, fp) != NULL)
      printf("%s", str);
  fclose(fp);
  return 0;

  //TODO Separate into training & testing set

  //TODO Call device function and run for declared amount of epochs

  //TODO Run new centroids against testing set and return accuracy
  
}