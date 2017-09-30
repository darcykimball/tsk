
#include <stdio.h>

#include <unistd.h>

#include <fcntl.h>

FILE * inline_c_Util_CStream_0_0f3d610b1a65a987857b0889cfc7744e6f391010(int dupedFdCInt_inline_c_0) {
return ( fdopen(dupedFdCInt_inline_c_0, "a") );
}


int inline_c_Util_CStream_1_4db382dfa8877d50b91321168db9539cabfbbab9(int fd_inline_c_0) {
return ( fcntl(fd_inline_c_0, F_GETFL) );
}

