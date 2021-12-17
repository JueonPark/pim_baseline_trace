#include <iostream>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <cublas.h>
#include <cuda_fp16.h>

/**
 * random number generation for matrix-vector
 **/
__global__ void generate_matrix_vector(int row, int col) {

}

/**
 * Simple matrix-vector-multiplication
 * C: result
 * A: 
 **/
__global__ void mv_multiply( float* C, float* A, float* B, int n) {
  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;
  float sum = 0.0f;
  for (int k = 0; k < n; k++) {
    sum += A[row*n+k] * B[k * n + col];
  }
  C[row*n+col] = sum;
}

/**
 * arguments: row, column
 * matrix-vector multiplication of (r*c) and c
 **/
int main(int argc, char** argv) {
  std::cout << argc << "\n";
  if (argc != 3) {
    assert(0 && "matrix-vector multiplication requires row and column argument");
  }
  int row = std::stoi(argv[1]);
  int col = std::stoi(argv[2]);

  float* a = (float*)malloc(row*col*sizeof(float));
  float* b = (float*)malloc(col*sizeof(float));
  float* c = (float*)malloc(row*sizeof(float));
  
  float *A, *B, *C;
  cublasInit();
  cublasAlloc(row * col, sizeof(float), (void**) &A);
  cublasAlloc(col * 1, sizeof(float), (void**) &B);
  cublasAlloc(row * 1, sizeof(float), (void**) &C);

  cublasSetMatrix(row, col, sizeof(float*), a, col, A, col);
  cublasSetVector(col, sizeof(float), b, 1, B, 1);

  float alpha = 1.0;
  float beta = 0.0;

  cublasSgemv('N', row, col, alpha, A, row, B, 1, beta, C, 1);

  return 0;
}
