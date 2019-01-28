# Simulating Low Precision Floating-Point Arithmetic
These MATALB codes provide efficient and accurate way to
simulate low precision floating point arithmetic, namely 
fp16 and bfloat16. They also provide options to use subnormal
numbers as well. 

## Related publications
* N. J. Higham, S. Pranesh. Simulating Low Precision Floating-Point Arithmetic

## Main Execution file
* **_Test.m_** Generates all the tables in the manuscript into the folder results/.
* **_test_chop.m_** Performs extensive testing of `chop' based rounding to low precision.


## Requirements
* The codes have been developed and tested with MATLAB 2018b.
* This code requires fp16 class from Cleve's Labaratory. It can be
downloaded from https://uk.mathworks.com/matlabcentral/fileexchange/59085-cleve_s-laboratory

## Contributors
* Nicholas. J. Higham 
* Srikara Pranesh
  
