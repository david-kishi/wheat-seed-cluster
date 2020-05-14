/******************************************************************************
* FILE: wheat_cluster.cu
* DESCRIPTION:
*   A simple cuda program to compute k-means cluster of a variety of wheat
*   wheat seeds.
* AUTHOR: David Nguyen
* CONTACT: david@knytes.com 
* REVISED: 14/05/2020
******************************************************************************/
#include <cuda.h>
#include <math.h>
#include <stdio.h>

#define AMT_OF_CLUSTERS = 3

//TODO Device function for k-means clustering
// Should return the new points of the centroids

int main(){
  // Read in dataset and store into array.
  // 210 total - 70 per class - put 10 random from each class
  float     *area,
            *perimeter,
            *compactness,
            *lenKernel,
            *widKernel,
            *asymCoef,
            *lenKernelGroove,
            *cat,
            *t_area,
            *t_perimeter,
            *t_compactness,
            *t_lenKernel,
            *t_widKernel,
            *t_asymCoef,
            *t_lenKernelGroove,
            *t_cat;

  // Allocate memory space to variables
  area = (float*)malloc(180*sizeof(float));
  perimeter = (float*)malloc(180*sizeof(float));
  compactness = (float*)malloc(180*sizeof(float));
  lenKernel = (float*)malloc(180*sizeof(float));
  widKernel = (float*)malloc(180*sizeof(float));
  asymCoef = (float*)malloc(180*sizeof(float));
  lenKernelGroove = (float*)malloc(180*sizeof(float));
  cat = (float*)malloc(180*sizeof(float));
  t_area = (float*)malloc(30*sizeof(float));
  t_perimeter = (float*)malloc(30*sizeof(float));
  t_compactness = (float*)malloc(30*sizeof(float));
  t_lenKernel = (float*)malloc(30*sizeof(float));
  t_widKernel = (float*)malloc(30*sizeof(float));
  t_asymCoef = (float*)malloc(30*sizeof(float));
  t_lenKernelGroove = (float*)malloc(30*sizeof(float));
  t_cat = (float*)malloc(30*sizeof(float));

  /**
  * Read in data from text file and store into training and testing sets
  */
  FILE  *fp; // File object
  float fTmp; // temporarily store float
  int   typeCount = 0, // keep count of feature
        trainingCount = 0, // keep count of size of training set
        entries = 0; // keep count of entry
  const char* filename = "seeds_dataset.txt"; // file name

  // Open file
  fp = fopen(filename, "r");

  // Check if file exists
  if (fp == NULL){
    printf("Could not open file %s",filename);
    return 1;
  }

  printf("READING DATASET\n%d: ", entries+1);
  while(entries != 210){
    fscanf(fp,"%6f",&fTmp);
    printf("%.4f ",fTmp);

    // Store value into proper array
    switch(typeCount){
      case 0: // area
        if((entries >= 60 && entries < 70) ||
            (entries >= 130 && entries < 140) ||
            (entries >= 200 && entries < 210)){
          t_area[trainingCount] = fTmp;
        }else{
          area[entries-trainingCount] = fTmp;
        }
        typeCount++;
      break;

      case 1: // perimeter
        if((entries >= 60 && entries < 70) ||
            (entries >= 130 && entries < 140) ||
            (entries >= 200 && entries < 210)){
          t_perimeter[trainingCount] = fTmp;
        }else{
          perimeter[entries-trainingCount]=fTmp;
        }
        typeCount++;
      break;

      case 2: // compactness
        if((entries >= 60 && entries < 70) ||
            (entries >= 130 && entries < 140) ||
            (entries >= 200 && entries < 210)){
          t_compactness[trainingCount] = fTmp;
        }else{
          compactness[entries-trainingCount]=fTmp;
        }
        typeCount++;
      break;

      case 3: // length of kernel
        if((entries >= 60 && entries < 70) ||
            (entries >= 130 && entries < 140) ||
            (entries >= 200 && entries < 210)){
          t_lenKernel[trainingCount] = fTmp;
        }else{
          lenKernel[entries-trainingCount]=fTmp;
        }
        typeCount++;
      break;

      case 4: // width of kernel
        if((entries >= 60 && entries < 70) ||
            (entries >= 130 && entries < 140) ||
            (entries >= 200 && entries < 210)){
          t_widKernel[trainingCount] = fTmp;
        }else{
          widKernel[entries-trainingCount]=fTmp;
        }
        typeCount++;
      break;

      case 5: // asymmetry coefficient
        if((entries >= 60 && entries < 70) ||
            (entries >= 130 && entries < 140) ||
            (entries >= 200 && entries < 210)){
          t_asymCoef[trainingCount] = fTmp;
        }else{
          asymCoef[entries-trainingCount]=fTmp;
        }
        typeCount++;
      break;

      case 6: // length of kernel groove
        if((entries >= 60 && entries < 70) ||
            (entries >= 130 && entries < 140) ||
            (entries >= 200 && entries < 210)){
          t_lenKernelGroove[trainingCount] = fTmp;          
        }else{
          lenKernelGroove[entries-trainingCount]=fTmp;
        };
        typeCount++;
      break;

      case 7: // class
        if((entries >= 60 && entries < 70) ||
            (entries >= 130 && entries < 140) ||
            (entries >= 200 && entries < 210)){
          t_cat[trainingCount] = fTmp;
          trainingCount++;
        }else{
          cat[entries-trainingCount]=fTmp;
        }
        typeCount = 0;
        entries++;
        if(entries != 210){
          printf("\n%d: ", entries+1);
        }else{
          printf("\n");
        }
      break;
      
      default:
        printf("Invalid entry during data read in.\n");
    }
  }

  // Close file
  fclose(fp);

  //TODO Call device function and run for declared amount of epochs

  //TODO Run new centroids against testing set and return accuracy
  

  // Free memory
  free(area);
  free(perimeter);
  free(compactness);
  free(lenKernel);
  free(widKernel);
  free(asymCoef);
  free(lenKernelGroove);
  free(cat);
  free(t_area);
  free(t_perimeter);
  free(t_compactness);
  free(t_lenKernel);
  free(t_widKernel);
  free(t_asymCoef);
  free(t_lenKernelGroove);
  free(t_cat);

  return 0;
}