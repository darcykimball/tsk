{-# LANGUAGE QuasiQuotes, TemplateHaskell #-}
module TSK.Internal.Volume where


import Control.Monad (when)
import Foreign.Marshal.Alloc
import Foreign.Ptr
import Foreign.C.Types
import Foreign.C.String


import qualified Data.ByteString as B -- FIXME: lazy or strict??
import qualified Language.C.Inline as C
import qualified Language.C.Inline.Unsafe as CU


import TSK.Internal.Callback
import TSK.Internal.Exception
import TSK.Internal.TH
import TSK.Internal.Types


C.context tskCtx

C.include "<tsk/libtsk.h>"


openVolume :: ImgInfo -> DiskAddr -> VSTypeEnum -> IO VSInfo
openVolume (ImgInfo ptr) daddr vsType = do
  VSInfo <$> throwOnNull [C.exp| TSK_VS_INFO* {
      tsk_vs_open(
        $(TSK_IMG_INFO* ptr),
        $(TSK_DADDR_T daddr),
        $(TSK_VS_TYPE_ENUM vsType))
    }
  |]


closeVolume :: VSInfo -> IO ()
closeVolume (VSInfo ptr) =
  [C.exp| void { tsk_vs_close($(TSK_VS_INFO* ptr)) } |]


readVolumeBlock :: VSInfo -> DiskAddr -> CSize -> IO B.ByteString
readVolumeBlock (VSInfo ptr) daddr numBytesToRead = do
  allocaBytes (fromIntegral numBytesToRead) $ \buf -> do
    retVal <- [C.exp| ssize_t {
                  tsk_vs_read_block(
                    $(TSK_VS_INFO* ptr),
                    $(TSK_DADDR_T daddr),
                    $(char* buf),
                    $(size_t numBytesToRead)
                  )
                }
              |]
  
    when (retVal == ssizeErrorVal) throwTSK

    B.packCString buf 


getPartition :: VSInfo -> PartAddr -> IO PartInfo
getPartition (VSInfo ptr) paddr = PartInfo <$> throwOnNull
  [C.exp| TSK_VS_PART_INFO* {
      tsk_vs_part_get($(TSK_VS_INFO* ptr), $(TSK_PNUM_T paddr))
    }
  |]


readPartitionBytes :: PartInfo -> Offset -> CSize -> IO B.ByteString
readPartitionBytes (PartInfo ptr) offset numBytesToRead = do
  allocaBytes (fromIntegral numBytesToRead) $ \buf -> do
    retVal <- [C.exp| ssize_t {
                  tsk_vs_part_read(
                    $(TSK_VS_PART_INFO* ptr),
                    $(TSK_OFF_T offset),
                    $(char* buf),
                    $(size_t numBytesToRead)
                  )
                }
              |]

    when (retVal == ssizeErrorVal) throwTSK

    B.packCString buf 


readPartitionBlockBytes :: PartInfo -> DiskAddr -> CSize -> IO B.ByteString
readPartitionBlockBytes (PartInfo ptr) daddr numBytesToRead = 
  allocaBytes (fromIntegral numBytesToRead) $ \buf -> do
    retVal <- [C.exp| ssize_t {
                  tsk_vs_part_read_block(
                    $(TSK_VS_PART_INFO* ptr),
                    $(TSK_DADDR_T daddr),
                    $(char* buf),
                    $(size_t numBytesToRead)
                  )
                }
              |]

    when (retVal == ssizeErrorVal) throwTSK

    B.packCString buf 

--
-- TODO/FIXME check purity...
supportedVSTypes :: VSTypeEnum
supportedVSTypes = [CU.pure| TSK_VS_TYPE_ENUM { tsk_vs_type_supported() } |]
  

-- TODO/FIXME check purity...
vsTypeToDesc :: VSTypeEnum -> IO CString
vsTypeToDesc vsType = throwOnNull
  [C.exp| const char* { tsk_vs_type_todesc($(TSK_VS_TYPE_ENUM vsType)) } |]


-- TODO/FIXME check purity...
vsTypeToInternalID :: CString -> IO CString
vsTypeToInternalID vsType = throwOnNull
  [C.exp| const char* { tsk_vs_type_toid($(const char* vsType)) } |]


vsTypeToName :: VSTypeEnum -> IO CString
vsTypeToName vsType = throwOnNull
  [C.exp| const char* { tsk_vs_type_toname$(TSK_VS_TYPE_ENUM vsType) } |]


vsPartWalk ::
     VSInfo
  -> PartAddr
  -> PartAddr
  -> PartFlags
  -> (VSInfo -> PartInfo -> IO CallbackRetEnum)
  -> IO ()
vsPartWalk (VSInfo ptr) start end flags callback = do
  wrapped <- wrapPartCallback callback

  -- TODO: make C indentation consistent ffs
  retVal <- [C.exp| uint8_t {
              tsk_vs_part_walk(
                $(TSK_VS_INFO* ptr),
                $(TSK_PNUM_T start),
                $(TSK_PNUM_T end),
                $(TSK_VS_PART_FLAG_ENUM flags),
                $(TSK_VS_PART_WALK_CB wrapped),
                $(void* nullPtr)
                )
              }
            |]
  
  when (retVal /= 0) throwTSK
