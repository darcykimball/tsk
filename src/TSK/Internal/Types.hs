{-# LINE 1 "Types.hsc" #-}
module TSK.Internal.Types where
{-# LINE 2 "Types.hsc" #-}


import Foreign.C.Types



{-# LINE 8 "Types.hsc" #-}


-- Enum of image type flags. 
newtype ImgType = ImgType CInt
  deriving (Eq, Ord, Show)

tskImgTypeDetect :: ImgType
tskImgTypeDetect = ImgType 0
tskImgTypeRaw :: ImgType
tskImgTypeRaw = ImgType 1
tskImgTypeRawSing :: ImgType
tskImgTypeRawSing = ImgType 1
tskImgTypeRawSplit :: ImgType
tskImgTypeRawSplit = ImgType 1
tskImgTypeAffAff :: ImgType
tskImgTypeAffAff = ImgType 4
tskImgTypeAffAfd :: ImgType
tskImgTypeAffAfd = ImgType 8
tskImgTypeAffAfm :: ImgType
tskImgTypeAffAfm = ImgType 16
tskImgTypeAffAny :: ImgType
tskImgTypeAffAny = ImgType 32
tskImgTypeEwfEwf :: ImgType
tskImgTypeEwfEwf = ImgType 64
tskImgTypeUnsupp :: ImgType
tskImgTypeUnsupp = ImgType 65535

{-# LINE 15 "Types.hsc" #-}

-- TODO: Add new support for VMDK, etc.??
