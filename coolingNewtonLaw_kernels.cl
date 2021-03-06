__kernel void pivotMedioKernel(__global int *rowMax, __global float *a, __global int *pivot, int n, int j)
{
	int i = 0;
	int k = 0;	
	int big = 0.0;
	rowMax[0] = j;
	for(i = j;i < n; i++){
		k = j;
		if(fabs(a[i*n+k]) > big){
			big = fabs(a[i*n+k]);
			rowMax[0] = i ;
		}
	}
	pivot[j] = rowMax[0];
}


__kernel void swapRowsKernel(__global int *rowMax, int j,__global float *a)
{
	
	if(rowMax[0] != j)
	{
		int i,n;
		local float temp;
		
		temp = 0.0;
		
		i = get_global_id(0);
		n = get_global_size(0);
		
		temp = a[(rowMax[0])*n+i];
		a[(rowMax[0])*n+i] = a[j*n+i];
		a[j*n+i] = temp;
	}
}

__kernel void computeBetaKernel(int n,__global float *a, int j)
{
	int i;
	int k;
 	float sumatoria;
	i = get_global_id(0) + j;
	sumatoria = 0.0;
	for(k = 0;k < j; k++)
		sumatoria = sumatoria + (a[j*n+k]*a[k*n+i]);		
	a[j*n+i] = a[j*n+i] - sumatoria;		
}


__kernel void computeAlphaKernel(int j, __global float *a, int n)
{
	int i;
	float sumatoria;
	int k;		
	i = get_global_id(0) + j;
	sumatoria = 0.0;
	for (k = 0; k <= j-1; k++)
		sumatoria = sumatoria + a[(i+1)*n+k]*a[k*n+j];
	a[(i+1)*n+j]= (1/a[j*n+j])*(a[(i+1)*n+j] - sumatoria);		
}



//////////////////////////Kernels solución sistema de ecuaciones //////////////////////

//Se lanzan n hilos. n es el numero de ecuaciones
__kernel void permutarVectorKernel(__global float *b, __global int *pivot){
	int i;
	i = get_global_id(0);
	float temp;
	if(i != pivot[i]){
		temp = b[i];
		b[i] = b[pivot[i]];
		b[pivot[i]] = temp;
	}	

}

//Se lanzan n hilos. n es el numero de ecuaciones
__kernel void solveSystemEquationsY(__global float *a,__global float *b,__global float *y){

	int i,j,n,ii;	
	float sumatoria;
	i = get_global_id(0);	
	n = get_global_size(0);

	if (i==0){
		for (ii = 0; ii < n; ii++) {
			sumatoria = 0.0;										//Forward sustitution ecuacion (4)
			for(j = 0; j <= ii - 1 ;j++)
				sumatoria = sumatoria + (a[ii*n+j]*y[j]);
			y[ii] = b[ii] - sumatoria;
		}		
	}
}

//Se lanzan n hilos. n es el numero de ecuaciones
__kernel void solveSystemEquationsX(__global float *a,__global float *x,__global float *y){

	float sumatoria;
	int i, n,j,ii;
	n = get_global_size(0);
	i = get_global_id(0);
	
	if (i == 0){
		for (ii = n-1 ; ii >= 0 ; ii--){
			sumatoria = 0.0;
			for(j = ii+1 ; j < n ;j++)
				sumatoria = sumatoria + (a[ii*n+j]*x[j]);//back sustitution ecuacion (5)
			x[ii] = (1/a[ii*n+ii])*(y[ii] - sumatoria);
		}
	}
}
