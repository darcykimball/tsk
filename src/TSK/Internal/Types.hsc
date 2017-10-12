{-# LANGUAGE EmptyDataDecls #-}
module TSK.Internal.Types where


import Control.Applicative
import Data.Int
import Data.Word
import Foreign.Ptr
import Foreign.C.Types
import Foreign.Storable

import qualified Data.Text as T
import qualified Data.Text.Encoding as TE


#include <tsk/libtsk.h>



-- XXX: Since TSK has to support both UTF-16 (Windows) and UTF-8, so I'm going
-- to do the ghetto thing and just use Text and convert to UTF-8 when passing
-- args to TSK (UTF-8 specific) functions
-- TODO: still necessary to test if Windows or not then? i.e. what TSK_TCHAR is?


--
-- Disk Image types
--


-- Enum of image type flags
newtype ImgTypeEnum = ImgTypeEnum CInt
  deriving (Eq, Ord, Show)

#enum ImgTypeEnum, ImgTypeEnum, TSK_IMG_TYPE_DETECT, TSK_IMG_TYPE_RAW, TSK_IMG_TYPE_RAW_SING, TSK_IMG_TYPE_RAW_SPLIT, TSK_IMG_TYPE_AFF_AFF, TSK_IMG_TYPE_AFF_AFD, TSK_IMG_TYPE_AFF_AFM, TSK_IMG_TYPE_AFF_ANY, TSK_IMG_TYPE_EWF_EWF, TSK_IMG_TYPE_UNSUPP


-- FIXME: Opaque??? Or Ptr to opaque?? How to handle concurrency???
data TSKLock


-- Type aliases
type Offset = #{type TSK_OFF_T}


-- TSK disk image info struct and opaque rep.
data ImgInfoStruct
newtype ImgInfo = ImgInfo { getImgInfoPtr :: (Ptr ImgInfoStruct) }


-- Raw accessors
peekImageType :: Ptr ImgInfoStruct -> IO CInt
peekImageType  = #{peek TSK_IMG_INFO, itype}

peekPageSize :: Ptr ImgInfoStruct -> IO CUInt
peekPageSize   = #{peek TSK_IMG_INFO, page_size}

peekSectorSize :: Ptr ImgInfoStruct -> IO CUInt
peekSectorSize = #{peek TSK_IMG_INFO, sector_size}

peekImageSize :: Ptr ImgInfoStruct -> IO Offset
peekImageSize  = #{peek TSK_IMG_INFO, size}

peekSpareSize :: Ptr ImgInfoStruct -> IO CUInt
peekSpareSize  = #{peek TSK_IMG_INFO, spare_size}
    

--
-- Filesystem types
--


-- TSK filesystem info struct
-- TODO
data FSInfo

-- Enum of filesystem types
newtype FSType = FSType CInt
  deriving (Eq, Ord, Show)
