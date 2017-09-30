{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}
module TSK.Internal.Base where


import Data.Word (Word32)
import Foreign.C.String (CString, peekCString, withCString)
import Foreign.C.Types
import System.IO (Handle)
import System.IO.Unsafe (unsafePerformIO)
import System.Posix.IO


import qualified Language.C.Inline as C
import qualified Language.C.Inline.Unsafe as CU


C.include "<tsk/libtsk.h>"


versionCString :: CString
versionCString = [CU.pure| const char* { TSK_VERSION_STR } |]


versionString :: String
versionString =  unsafePerformIO (peekCString versionCString)


getErrorCString :: IO CString
getErrorCString = [C.exp| const char* { tsk_error_get() } |]


getErrorString :: IO String
getErrorString = getErrorCString >>= peekCString


-- XXX: Dammit. The return type of the C function is uint32_t, but
-- Foreign.C.Types only includes 'unsigned int/long', of which only the long
-- version is guaranteed to be at least 32 bits. There should be a better and
-- cleaner way.
getErrorNo :: IO Word32
getErrorNo = [C.exp| uint32_t { tsk_error_get_errno() } |]


printError :: Handle -> IO ()
printError =  error "TODO!"


resetError :: IO ()
resetError = [C.exp| void { tsk_error_reset() } |]


foo :: Show a => a -> IO ()
foo a =
  withCString (show a) $
    \cStr -> [C.block| void { fprintf(stderr, $(char const* cStr)); } |]
