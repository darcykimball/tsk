{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
module TSK.Internal.FileSystem where


import Foreign.C.String
import Foreign.C.Types

import qualified Language.C.Inline as C

import TSK.Internal.TH
import TSK.Internal.Types


C.context tskCtx

C.include "tsk/libtsk.h"


fsTypeIsNTFS, fsTypeIsFAT, fsTypeIsFFS, fsTypeIsEXT :: FSTypeEnum -> Bool
fsTypeIsISO9660, fsTypeIsHFS, fsTypeIsSwap          :: FSTypeEnum -> Bool
fsTypeIsYAFFS2, fsTypeIsRaw                          :: FSTypeEnum -> Bool


fsTypeIsNTFS fsType =
  [C.pure| int { TSK_FS_TYPE_ISNTFS($(TSK_FS_TYPE_ENUM fsType)) } |] /= 0

fsTypeIsFAT fsType =
  [C.pure| int { TSK_FS_TYPE_ISFAT($(TSK_FS_TYPE_ENUM fsType)) } |] /= 0

fsTypeIsFFS fsType =
  [C.pure| int { TSK_FS_TYPE_ISFFS($(TSK_FS_TYPE_ENUM fsType)) } |] /= 0

fsTypeIsEXT fsType =
  [C.pure| int { TSK_FS_TYPE_ISEXT($(TSK_FS_TYPE_ENUM fsType)) } |] /= 0

fsTypeIsISO9660 fsType =
  [C.pure| int { TSK_FS_TYPE_ISISO9660($(TSK_FS_TYPE_ENUM fsType)) } |] /= 0

fsTypeIsHFS fsType =
  [C.pure| int { TSK_FS_TYPE_ISHFS($(TSK_FS_TYPE_ENUM fsType)) } |] /= 0

fsTypeIsSwap fsType =
  [C.pure| int { TSK_FS_TYPE_ISSWAP($(TSK_FS_TYPE_ENUM fsType)) } |] /= 0

fsTypeIsYAFFS2 fsType =
  [C.pure| int { TSK_FS_TYPE_ISYAFFS2($(TSK_FS_TYPE_ENUM fsType)) } |] /= 0

fsTypeIsRaw fsType =
  [C.pure| int { TSK_FS_TYPE_ISRAW($(TSK_FS_TYPE_ENUM fsType)) } |] /= 0
