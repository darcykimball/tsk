{-# LANGUAGE EmptyDataDecls #-}
module TSK.Internal.Types where


import Foreign.C.Types
import Foreign.Storable


#include <tsk/libtsk.h>


-- Enum of image type flags
newtype ImgType = ImgType CInt
  deriving (Eq, Ord, Show)

#enum ImgType, ImgType, TSK_IMG_TYPE_DETECT, TSK_IMG_TYPE_RAW, TSK_IMG_TYPE_RAW_SING, TSK_IMG_TYPE_RAW_SPLIT, TSK_IMG_TYPE_AFF_AFF, TSK_IMG_TYPE_AFF_AFD, TSK_IMG_TYPE_AFF_AFM, TSK_IMG_TYPE_AFF_ANY, TSK_IMG_TYPE_EWF_EWF, TSK_IMG_TYPE_UNSUPP


-- Enum of filesystem types
newtype FSType = FSType CInt
  deriving (Eq, Ord, Show)

-- TODO hsc shit


-- TODO: Add new (4.3) support for VMDK, etc.?? Check other random shit??


-- FIXME: Opaque??? Or Ptr to opaque??
data TSKLock


-- Type aliases
type Offset = #{type TSK_OFF_T}
type UInt = #{type unsigned int}



-- TSK disk image info struct.
data ImgInfo = ImgInfo {
    _imgType :: ImgType
  , _size :: #{type TSK_OFF_T} -- FIXME: safe??
  , _sectorSize :: CUInt
  , _pageSize :: CUInt
  , _spareSize :: CUInt
  }


-- Even lower level access
data ImgInfoStruct
type RawImgInfoPtr = ForeignPtr ImgInfoStruct


-- TODO!
instance Storable ImgInfo where
  alignment _ = (#alignment TSK_IMG_INFO)
  sizeOf _ = #{size TSK_IMG_INFO}

  poke = error "Unimplemented. ImgInfo's are read-only!"

  peek ptr = ImgInfo {
      _imgType = #{peek TSK_IMG_INFO, itype}
      _size = #{peek TSK_IMG_INFO, itype}
      _sectorSize = #{peek TSK_IMG_INFO, sector_size }
      _numImages = #{peek TSK_IMG_INFO, num_img}
      _spareSize = #{peek TSK_IMG_INFO spare_size}
      _pageSize = #{peek TSK_IMG_INFO page_size}
      _imgType = #{peek TSK_IMG_INFO itype}
    }


-- TSK filesystem info struct
-- TODO
data FSInfo
