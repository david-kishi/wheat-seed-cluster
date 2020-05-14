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
            *cat;

  // Allocate memory space to variables
  area = (float*)malloc(210*sizeof(float));
  perimeter = (float*)malloc(210*sizeof(float));
  compactness = (float*)malloc(210*sizeof(float));
  lenKernel = (float*)malloc(210*sizeof(float));
  widKernel = (float*)malloc(210*sizeof(float));
  asymCoef = (float*)malloc(210*sizeof(float));
  lenKernelGroove = (float*)malloc(210*sizeof(float));
  cat = (float*)malloc(210*sizeof(float));

  /**
  * Read in data from text file.
  */
  FILE  *fp; // File object
  float fTmp; // temporarily store float
  int   typeCount = 0, // keep count of feature
        entries = 0;
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

    switch(typeCount){
      case 0: // area
        area[entries] = fTmp;
        typeCount++;
      break;

      case 1: // perimeter
        perimeter[entries] = fTmp;
        typeCount++;
      break;

      case 2: // compactness
        compactness[entries] = fTmp;
        typeCount++;
      break;

      case 3: // length of kernel
        lenKernel[entries] = fTmp;
        typeCount++;
      break;

      case 4: // width of kernel
        widKernel[entries] = fTmp;
        typeCount++;
      break;

      case 5: // asymmetry coefficient
        asymCoef[entries] = fTmp;
        typeCount++;
      break;

      case 6: // length of kernel groove
        lenKernelGroove[entries] = fTmp;
        typeCount++;
      break;

      case 7: // class
        cat[entries] = fTmp;
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

  //TODO Separate into training & testing set

  //TODO Call device function and run for declared amount of epochs

  //TODO Run new centroids against testing set and return accuracy
  

  // Free memory
  // free(area);
  // free(perimeter);
  // free(compactness);
  // free(lenKernel);
  // free(widKernel);
  // free(asymCoef);
  // free(lenKernelGroove);
  // free(class);

  return 0;
}