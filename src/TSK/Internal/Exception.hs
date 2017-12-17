{-# LANGUAGE DeriveDataTypeable #-}
module TSK.Internal.Exception where


import Control.Monad (when)
import Foreign.Ptr


import Control.Exception
import Data.Int (Int64)


import TSK.Internal.Base


-- This type encapsulates all exceptions arising from TSK library calls
data TSKException = TSKException String
  deriving (Show)

instance Exception TSKException


-- Throw a TSK exception, passing the current error string and resetting it
throwTSK :: IO a
throwTSK = do
  errMsg <- getErrorString
  resetError
  throwIO $ TSKException errMsg

-- TODO/FIXME: uh...use errstr or errstr2?? both??


ssizeErrorVal :: Int64
ssizeErrorVal = fromIntegral (-1)


-- Make an action throw a TSK exceptino if the return value is the null ptr.
throwOnNull :: IO (Ptr a) -> IO (Ptr a)
throwOnNull io = do
  retVal <- io
  when (retVal == nullPtr) throwTSK
  return retVal
