{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
module Util.CStream (
    CStream
  , handleToCStream
  , withHandleAsCStream
  ) where


import Control.Exception (bracket)
import Foreign.C.String
import Foreign.C.Types
import Foreign.Ptr
import GHC.IO.Handle
import System.IO
import System.Posix.IO
import System.Posix.Types (Fd(..))


import qualified Language.C.Inline as C


-- The CStream type; just a wrapper around FILE*
-- FIXME: Does CFile from base even hold any data??? Well, for this, it's just
-- important that the pointer is typed, I guess???
newtype CStream = CStream (Ptr CFile)


-- For fopen & co.
C.include "<stdio.h>"
C.include "<unistd.h>"
C.include "<fcntl.h>"


--  Convert a handle to a stream (i.e. FILE*). The embedded value is the
--  converted stream and the associated cleanup action (fclose())
handleToCStream :: Handle -> IO (CStream, IO ())
handleToCStream h = do
  dupedHdl <- hDuplicate h
  fd <- handleToFd dupedHdl
  dupedFd@(Fd dupedFdCInt) <- dup fd

  -- FIXME: Check Handle's mode and propagate??
  -- FIXME: Exception handling/progagation from fdopen(); check retval??
  streamPtr <- [C.exp| FILE* { fdopen($(int dupedFdCInt), "a") } |]

  return (CStream streamPtr, closeFd dupedFd)


withHandleAsCStream :: Handle -> (CStream -> IO a) -> IO a
withHandleAsCStream h f =
  bracket
    (handleToCStream h)
    (\(_, cleanup) -> cleanup) -- XXX: Hopefully clearer than 'snd'
    (\(stream, _) -> f stream)



-- FIXME
-- Query the mode on a handle and return a CString representing its r/w mode.
-- Result value can be passed to fopen().
getModeCString :: Handle -> IO CString
getModeCString h = do
  error "TODO!"


-- Just a wrapper around fcntl() for getting mode flags.
getFdMode :: Fd -> IO CInt
getFdMode (Fd fd) = [C.exp| int { fcntl($(int fd), F_GETFL) } |]


-- Convert mode flags to a C string appropriate for passing to fdopen().
modeFlagsToCString :: CInt -> CString
modeFlagsToCString = error "TODO"



