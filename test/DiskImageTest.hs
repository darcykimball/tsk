{-# LANGUAGE OverloadedStrings #-}
import System.Exit

import qualified Data.Text as T


import TSK.Internal.DiskImage
import TSK.Internal.Types


main :: IO ()
main = do
  -- FIXME what path does this run from, or how to get it??
  imgInfo <- openSingleImage "/home/ubuntu/hsbits/tsk/test/test.img" tskImgTypeDetect 0

  imgType     <- getImageType imgInfo
  pageSize    <- getPageSize imgInfo
  sectorSize  <- getSectorSize imgInfo
  imgSize     <- getImageSize imgInfo
  spareSize   <- getSpareSize imgInfo


  putStrLn $ "Type: " ++ show imgType
  putStrLn $ "Page size: " ++ show pageSize
  putStrLn $ "Sector size: " ++ show sectorSize
  putStrLn $ "Total size: " ++ show imgSize
  putStrLn $ "Spare size: " ++ show spareSize
  




  putStrLn $ "Image type: " ++ show imgType

  exitWith $ ExitSuccess
