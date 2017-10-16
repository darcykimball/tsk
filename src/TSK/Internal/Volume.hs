module TSK.Internal.Volume where



import Foreign.C.Types

import qualified Data.ByteString as B -- FIXME: lazy or strict??


import TSK.Internal.Types


openVolume :: ImgInfo -> DiskAddr -> VSTypeEnum -> IO VSInfo
openVolume = error "TODO"


closeVolume :: VSInfo -> IO ()
closeVolume = error "TODO"


getPartition :: VSInfo -> PartAddr -> IO PartInfo
getPartition = error "TODO"


readPartitionBytes :: PartInfo -> Offset -> CSize -> IO B.ByteString
readPartitionBytes = error "TODO"


readPartitionBlockBytes :: PartInfo -> DiskAddr -> CSize -> IO B.ByteString
readPartitionBlockBytes = error "TODO"


traversePartitions ::
  PartAddr -> PartAddr -> (PartInfo -> IO a) -> VSInfo -> IO [a]
traversePartitions = error "TODO"
