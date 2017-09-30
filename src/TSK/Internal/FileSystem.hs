{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
module TSK.Internal.FileSystem where


import Foreign.C.String
import Foreign.C.Types

import qualified Language.C.Inline as C


C.include "tsk/libtsk.h"


versionStr :: IO CString
versionStr = [C.exp| const char* { tsk_version_get_str() } |]
