module TSK.Internal.Util where


import Data.Word
import Foreign.C.Types


getCUInt :: CUInt -> Word32
getCUInt (CUInt n) = n
