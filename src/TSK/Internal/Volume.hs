{-# LANGUAGE QuasiQuotes, TemplateHaskell #-}
module TSK.Internal.Volume where


import Control.Monad (when)
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


getPartition :: VSInfo -> PartAddr -> IO PartInfo
getPartition (VSInfo ptr) paddr = PartInfo <$> throwOnNull
  [C.exp| TSK_VS_PART_INFO* {
      tsk_vs_part_get($(TSK_VS_INFO* ptr), $(TSK_PNUM_T paddr))
    }
  |]


readPartitionBytes :: PartInfo -> Offset -> CSize -> IO B.ByteString
readPartitionBytes = error "TODO"


readPartitionBlockBytes :: PartInfo -> DiskAddr -> CSize -> IO B.ByteString
readPartitionBlockBytes = error "TODO"


traversePartitions ::
  PartAddr -> PartAddr -> (PartInfo -> IO a) -> VSInfo -> IO [a]
traversePartitions = error "TODO"


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
  -> PartFlagsEnum
  -> (VSInfo -> PartInfo -> IO CallbackRetEnum)
  -> IO ()
vsPartWalk (VSInfo ptr) start end flags callback = do
  wrapped <- wrapPartCallback callback

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
