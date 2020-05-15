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

/**
 * Device function to perform 1 pass of k-means clustering
 *  @param  {float*} x - array of a feature
 *  @param  {float*} y - array of a feature
 *  @param  {int} amt - amount of values (30 or 180)
 *  @param  {float*} cents - centroid coordinates
 *  @param  {float*} predict - array to hold predicted class values
 */
__global__
void kMeansClustering(float *x, float *y, int amt, float *cents, float *predict){
  for(int i = 0; i < amt; i++){
    int tid = blockIdx.x * blockDim.x + threadIdx.x;

    // Compute Euclidean Distances
    float eucD_a = sqrt(pow(x[tid] - cents[0], 2) + pow(y[tid] - cents[1], 2));
    float eucD_b = sqrt(pow(x[tid] - cents[2], 2) + pow(y[tid] - cents[3], 2));
    float eucD_c = sqrt(pow(x[tid] - cents[4], 2) + pow(y[tid] - cents[5], 2));

    // Compare Euclidean Distances
    if(eucD_a <= eucD_b && eucD_a <= eucD_c){
      predict[tid] = 1;
    }else if(eucD_b <= eucD_a && eucD_b <= eucD_c){
      predict[tid] = 2;
    }else{
      predict[tid] = 3;
    }
  }
}

/**
 * Host function to check predictions
 *  @param  {float*} pred - array of predictions
 *  @param  {float*} act - array of actual class
 *  @param  {int} amt - amount of predicted values (30 or 180)
 */
__host__
void checkPredictions(float *pred, float *act, int amt){
  int falseCnt = 0;
  for(int i = 0; i < amt; i++){
    if(pred[i] != act[i]) { falseCnt++; }
  }
  printf("Correct Predictions: %d/%d\n",amt-falseCnt, amt);
  printf("Accuracy: %.4f\n", 1.0*(amt-falseCnt)/amt);
}

/**
 * Host function to update centroid coordinates
 *  @param  {float*} x - array of a feature
 *  @param  {float*} y - array of a feature
 *  @param  {int} amt - amount of predicted values (30 or 180)
 */
__host__
void updateCentroids(float *x, float *y, float *pred, float *cent){
  float centA_x = 0,
        centA_y = 0,
        centB_x = 0,
        centB_y = 0,
        centC_x = 0,
        centC_y = 0;
  
  // Sum of values
  for(int i = 0; i < 180; i++){
    if(pred[i] == 1.0){
      centA_x += x[i];
      centA_y += y[i];
    }else if(pred[i] == 2.0){
      centB_x += x[i];
      centB_y += y[i];
    }else{
      centC_x += x[i];
      centC_y += y[i];
    }
  }

  // Compute new centroids
  cent[0] = centA_x / 180;
  cent[1] = centA_y / 180;
  cent[2] = centB_x / 180;
  cent[3] = centB_y / 180;
  cent[4] = centC_x / 180;
  cent[5] = centC_y / 180;
}

int main(){
  // Read in dataset and store into array.
  // 210 total - 70 per class - put 10 random from each class
  float *area,
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
        *t_cat,
        *predicted_180,
        *predicted_30,
        *predicted_180_d,
        *predicted_30_d,
        *centroids,
        *centroids_d,
        *a,
        *b;

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
  predicted_180 = (float*)malloc(180*sizeof(float));
  predicted_30 = (float*)malloc(30*sizeof(float));
  centroids = (float*)malloc(6*sizeof(float));

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

  printf("Reading in dataset...\n");
  while(entries != 210){
    fscanf(fp,"%6f",&fTmp);

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
      break;
      
      default:
        printf("Invalid entry during data read in.\n");
    }
  }

  // Close file
  fclose(fp);
  printf("Finished reading.\n");

  // Choose initial centroids
  centroids[0] = area[0];
  centroids[1] = perimeter[0];
  centroids[2] = area[60];
  centroids[3] = perimeter[60];
  centroids[4] = area[120];
  centroids[5] = perimeter[120];

  //TODO Call device function and run for declared amount of epochs
  // Allocate memory to device
  cudaMalloc(&a, 180*sizeof(float));
  cudaMalloc(&b, 180*sizeof(float));
  cudaMalloc(&centroids_d, 6*sizeof(float));
  cudaMalloc(&predicted_180_d, 180*sizeof(float));

  // Copy data to device memory
  cudaMemcpy(a, area, 180*sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(b, perimeter, 180*sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(centroids_d, centroids, 6*sizeof(float), cudaMemcpyHostToDevice);
  
  // Call Device Function - kMeansClustering
  printf("Initiating 1-pass of k-means clustering.\n");
  kMeansClustering<<<1,180>>>(a,b, 180, centroids_d, predicted_180_d);
  printf("Completed.\n");

  // Copy result from device memory
  cudaMemcpy(centroids, centroids_d, 6*sizeof(float), cudaMemcpyDeviceToHost);
  cudaMemcpy(predicted_180, predicted_180_d, 180*sizeof(float), cudaMemcpyDeviceToHost);

  checkPredictions(predicted_180, cat, 180);

  printf("Initial Centroids:\n");
  for(int i = 0; i < 3; i++){
    printf("(%.4f, %.4f)\n", centroids[2*i], centroids[2*i+1]);
  }

  updateCentroids(area, perimeter, predicted_180, centroids);

  printf("Updated Centroids:\n");
  for(int i = 0; i < 3; i++){
    printf("(%.4f, %.4f)\n", centroids[2*i], centroids[2*i+1]);
  }
  

  // Free all memory
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
  free(predicted_180);
  free(predicted_30);
  free(centroids);
  cudaFree(centroids_d);
  cudaFree(a);
  cudaFree(b);

  return 0;
}