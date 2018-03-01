{-# LANGUAGE QuasiQuotes, TemplateHaskell #-}
module TSK.Internal.DiskImage where


import Control.Monad (when, forM_)
import Data.List
import Data.Word
import Foreign.Ptr
import Foreign.C.String
import Foreign.C.Types
import Foreign.Marshal.Alloc
import Foreign.Marshal.Array
import Foreign.Storable

import qualified Data.ByteString as B -- FIXME: should use lazy or strict??
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Language.C.Inline as C


import TSK.Internal.Exception
import TSK.Internal.TH
import TSK.Internal.Types
import TSK.Internal.Util


C.context tskCtx

C.include "<tsk/libtsk.h>"


--
-- ImgInfo I/O
--


openImage :: [T.Text] -> ImgTypeEnum -> CUInt -> IO ImgInfo
openImage imgPaths imgType sectorSize = do
  withCStrings sortedPathBytes $ \paths ->
    -- Make a C list of strings
    allocaBytes numImgs $ \strList -> do
      forM_ [0 .. numImgs - 1] (\i -> pokeElemOff strList i (paths !! i))
    
      ImgInfo <$> throwOnNull
        [C.exp| TSK_IMG_INFO* {
            tsk_img_open_utf8(
              $(int intNumImgs),
              $(const char* const* strList),
              $(TSK_IMG_TYPE_ENUM imgType),
              $(unsigned int sectorSize)
            )
          }
        |]   
  where
    sortedPathBytes = map TE.encodeUtf8 $ sort imgPaths
    numImgs = length imgPaths
    intNumImgs = fromIntegral numImgs


    -- XXX:  Helper for making an array of CStrings
    withCStrings :: [B.ByteString] -> ([CString] -> IO a) -> IO a
    withCStrings []       f = f []
    withCStrings (s:rest) f = B.useAsCString s $ \cstr ->
      withCStrings rest (\cstrs -> f (cstr:cstrs))


openSingleImage :: T.Text -> ImgTypeEnum -> CUInt -> IO ImgInfo
openSingleImage path imgType sectorSize =
  B.useAsCString (TE.encodeUtf8 path) $ \path' -> do
    ImgInfo <$> throwOnNull
      [C.exp| TSK_IMG_INFO* {
          tsk_img_open_utf8_sing(
            $(const char* path'),
            $(TSK_IMG_TYPE_ENUM imgType),
            $(unsigned int sectorSize)
          )
        }
      |] 


closeImage :: ImgInfo -> IO ()
closeImage (ImgInfo ptr) =
  [C.exp| void { tsk_img_close($(TSK_IMG_INFO* ptr)); } |]


-- XXX: There's gotta be a better, possibly less safe but faster way to do this
readImageBytes :: ImgInfo -> Offset -> Word64 -> IO B.ByteString
readImageBytes (ImgInfo ptr) offset n =
  allocaArray (fromIntegral n) $ \buf -> do
    retVal <- [C.exp| ssize_t {
        tsk_img_read(
          $(TSK_IMG_INFO* ptr),
          $(TSK_OFF_T offset),
          $(char* buf),
          $(size_t numBytesToRead))
      }
    |]
   
    when (retVal == ssizeErrorVal) throwTSK 

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


getPageSize :: ImgInfo -> IO CUInt 
getPageSize = peekPageSize . getImgInfoPtr


getSectorSize :: ImgInfo -> IO CUInt 
getSectorSize = peekSectorSize . getImgInfoPtr


getImageSize :: ImgInfo -> IO Offset
getImageSize = peekImageSize . getImgInfoPtr


getSpareSize :: ImgInfo -> IO CUInt
getSpareSize = peekSpareSize . getImgInfoPtr
