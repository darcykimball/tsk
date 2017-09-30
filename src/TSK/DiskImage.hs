module TSK.DiskImage where


import qualified Data.ByteString as B
import qualified Data.Text as T


-- XXX: So, I've decided that Image (haskell type) should be opaque


-- FIXME? should use whatever TSK typedefs; recorded in Internal.Types...
type SectorSize = Word32
type Offset = Word32
type Size = Offset


openImages ::
  Int -> -- Number of images
  [T.Text] -> -- Image names
  Maybe ImageType -> -- Image type; if Nothing, then autodetect
  Maybe SectorSize -> -- Sector size; if Nothing, then use TSK's default
  IO Image 
openImages = error "TODO"


openImage ::
  T.Text -> -- Image name
  Maybe ImageType -> -- Image type; if Nothing, then autodetect
  Maybe SectorSize -> -- Sector size; if Nothing, then use TSK's default
  IO Image 
openImage = error "TODO"


closeImage :: Image -> IO ()
closeImage = error "TODO"


readImage :: Image -> Offset -> Size -> B.ByteString
readImage = error "TODO"


nameOfImageType :: ImageType -> T.Text
nameOfImageType = error "TODO"


parseImageType :: T.Text -> Maybe ImageType
parseImageType = error "TODO"


isAFF, isEWF, isRAW :: ImageType -> Bool
isAFF = error "TODO"
isEWF = error "TODO"
isRAW = error "TODO"


--
-- Image info
--


imageNames :: Image -> [T.Text]
imageNames = error "TODO"


imageType :: Image -> ImageType
imageType = error "TODO"


imageNumImages :: Integral a => Image -> a
imageNumImages = error "TODO"


imagePageSize :: Image -> Size
imagePageSize 


imageSize :: Image -> Size
imageSize = error "TODO"


imageSectorSize :: Image -> Size 
imageSectorSize = error "TODO"


imageSpareSize :: Image -> Size
imageSpareSize = error "TODO"
