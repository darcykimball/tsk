{-# LANGUAGE QuasiQuotes, TemplateHaskell #-}
module TSK.Internal.DiskImage (
    imgTypeIsAFF
  , imgTypeIsEWF
  , imgTypeIsRAW
  ) where


import Foreign.C.Types
import qualified Language.C.Inline as C


import TSK.Internal.Types


C.include "<tsk/libtsk.h>"


imgTypeIsAFF :: ImgType -> Bool
imgTypeIsAFF (ImgType imgType) =
  [C.pure| int { TSK_IMG_TYPE_ISAFF($(int imgType)) } |] /= 0


imgTypeIsEWF :: ImgType -> Bool
imgTypeIsEWF (ImgType imgType) =
  [C.pure| int { TSK_IMG_TYPE_ISEWF($(int imgType)) } |] /= 0


imgTypeIsRAW :: ImgType -> Bool
imgTypeIsRAW (ImgType imgType) =
  [C.pure| int { TSK_IMG_TYPE_ISRAW($(int imgType)) } |] /= 0



