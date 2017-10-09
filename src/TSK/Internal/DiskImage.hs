{-# LANGUAGE QuasiQuotes, TemplateHaskell #-}
module TSK.Internal.DiskImage (
    imgTypeIsAFF
  , imgTypeIsEWF
  , imgTypeIsRAW
  ) where


import Data.Word
import Foreign.Ptr
import Foreign.C.Types
import Foreign.Marshal.Array

import qualified Data.ByteString as B -- FIXME: should use lazy or strict??
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Language.C.Inline as C


import TSK.Internal.TH
import TSK.Internal.Types
import TSK.Internal.Util


C.context tskCtx

C.include "<tsk/libtsk.h>"


--
-- ImgInfo I/O
--


openImage :: [T.Text] -> ImgTypeEnum -> CUInt -> IO ImgInfo
openImage = error "TODO"


-- TODO: error handling...
openSingleImage :: T.Text -> ImgTypeEnum -> CUInt -> IO ImgInfo
openSingleImage path imgType sectorSize =
  B.useAsCString (TE.encodeUtf8 path) $ \path' -> do
    retVal <- 
      [C.exp| TSK_IMG_INFO* {
          tsk_img_open_utf8_sing(
            $(const char* path'),
            $(TSK_IMG_TYPE_ENUM imgType),
            $(unsigned int sectorSize)
          )
        }
      |] 

  -- TODO: check how Ptr Eq is implemented!!
    if retVal == nullPtr then error "FIXME" else return $ ImgInfo retVal


closeImage :: ImgInfo -> IO ()
closeImage (ImgInfo ptr) =
  [C.exp| void { tsk_img_close($(TSK_IMG_INFO* ptr)); } |]


-- XXX: There's gotta be a better, possibly less safe but faster way to do this
readImageBytes :: ImgInfo -> Offset -> Word64 -> IO B.ByteString
readImageBytes (ImgInfo ptr) (Offset offset) n =
  allocaArray (fromIntegral n) $ \buf -> do
    retVal <- [C.exp| ssize_t {
        tsk_img_read(
          $(TSK_IMG_INFO* ptr),
          $(TSK_OFF_T offset),
          $(char* buf),
          $(size_t numBytesToRead)
      }
    |]
   
    -- FIXME: error checking!!
    B.packCString buf 
  where
    numBytesToRead = CSize n


--
-- Operations on ImgInfo
--


imgTypeIsAFF :: ImgTypeEnum -> Bool
imgTypeIsAFF (ImgTypeEnum imgType) =
  [C.pure| int { TSK_IMG_TYPE_ISAFF($(int imgType)) } |] /= 0


imgTypeIsEWF :: ImgTypeEnum -> Bool
imgTypeIsEWF (ImgTypeEnum imgType) =
  [C.pure| int { TSK_IMG_TYPE_ISEWF($(int imgType)) } |] /= 0


imgTypeIsRAW :: ImgTypeEnum -> Bool
imgTypeIsRAW (ImgTypeEnum imgType) =
  [C.pure| int { TSK_IMG_TYPE_ISRAW($(int imgType)) } |] /= 0


getImageType :: ImgInfo -> IO ImgTypeEnum
getImageType = fmap ImgTypeEnum . peekImageType . getImgInfoPtr 


getPageSize :: ImgInfo -> IO Word32 
getPageSize = fmap getCUInt . peekPageSize . getImgInfoPtr


getSectorSize :: ImgInfo -> IO Word32 
getSectorSize = fmap getCUInt . peekSectorSize . getImgInfoPtr


getImageSize :: ImgInfo -> IO Offset
getImageSize = fmap getOffset . peekImageSize . getImgInfoPtr


getSpareSize :: ImgInfo -> IO Word32
getSpareSize = fmap getCUInt . peekSpareSize . getImgInfoPtr
