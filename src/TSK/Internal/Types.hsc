{-# LANGUAGE EmptyDataDecls #-}
module TSK.Internal.Types where


import Control.Applicative
import Data.Int
import Data.Word
import Foreign.Ptr
import Foreign.C.String
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

#{enum ImgTypeEnum, ImgTypeEnum, TSK_IMG_TYPE_DETECT, TSK_IMG_TYPE_RAW, TSK_IMG_TYPE_RAW_SING, TSK_IMG_TYPE_RAW_SPLIT, TSK_IMG_TYPE_AFF_AFF, TSK_IMG_TYPE_AFF_AFD, TSK_IMG_TYPE_AFF_AFM, TSK_IMG_TYPE_AFF_ANY, TSK_IMG_TYPE_EWF_EWF, TSK_IMG_TYPE_UNSUPP}


-- FIXME: Opaque??? Or Ptr to opaque?? How to handle concurrency???
data TSKLock


-- Type aliases
type Offset = #{type TSK_OFF_T}


-- TSK disk image info struct and opaque rep.
data ImgInfoStruct
newtype ImgInfo = ImgInfo { getImgInfoPtr :: (Ptr ImgInfoStruct) }


-- Raw accessors for ImgInfoStruct
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
-- Volume system types
--


newtype VSTypeEnum = VSTypeEnum CInt
  deriving (Eq, Ord, Show)


newtype PartFlagsEnum = PartFlagsEnum CInt
  deriving (Eq, Ord, Show)


newtype EndiannessEnum = EndiannessEnum CInt
  deriving (Eq, Ord, Show)
  

data VSInfoStruct
newtype VSInfo = VSInfo { getVSInfoStruct :: Ptr VSInfoStruct }


-- Raw accessors for VSInfoStruct
peekVSType :: Ptr VSInfoStruct -> IO CInt
peekVSType  = #{peek TSK_VS_INFO, vstype}

peekEndianness :: Ptr VSInfoStruct -> IO CInt
peekEndianness  = #{peek TSK_VS_INFO, block_size}

peekBlockSize :: Ptr VSInfoStruct -> IO CUInt
peekBlockSize  = #{peek TSK_VS_INFO, block_size}

peekOffsetInImg :: Ptr VSInfoStruct -> IO DiskAddr
peekOffsetInImg  = #{peek TSK_VS_INFO, offset}

peekNumPartitions :: Ptr VSInfoStruct -> IO PartAddr
peekNumPartitions = #{peek TSK_VS_INFO, part_count}


data PartInfoStruct
newtype PartInfo = PartInfo { getPartInfoStruct :: Ptr PartInfoStruct }


-- Raw accessors for PartInfoStruct
peekPartAddr :: Ptr PartInfoStruct -> IO PartAddr
peekPartAddr = #{peek TSK_VS_PART_INFO, addr}

peekDescription :: Ptr PartInfoStruct -> IO CString
peekDescription = #{peek TSK_VS_PART_INFO, desc}

peekNumSectors :: Ptr PartInfoStruct -> IO DiskAddr
peekNumSectors = #{peek TSK_VS_PART_INFO, len}

peekStartAddr :: Ptr PartInfoStruct -> IO DiskAddr
peekStartAddr = #{peek TSK_VS_PART_INFO, start}

peekPartFlags :: Ptr PartInfoStruct -> IO CInt
peekPartFlags = #{peek TSK_VS_PART_INFO, flags}


type PartAddr = #{type TSK_PNUM_T}


type DiskAddr = #{type TSK_DADDR_T}


--
-- Filesystem types
--


-- TSK filesystem info struct
-- TODO
data FSInfoStruct
newtype FSInfo = FSInfo { getFSInfoStruct :: Ptr FSInfoStruct }


-- Enum of filesystem types
newtype FSType = FSType CInt
  deriving (Eq, Ord, Show)
