{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes, TemplateHaskell #-}
{-# LANGUAGE RecordWildCards #-}
module TSK.Internal.TH (
    tskCtx
  ) where



import Data.Int (Int64(..))
import Language.C.Types
import Language.C.Inline.Context

import qualified Data.Map.Lazy as M
import qualified Language.C.Inline as C


import TSK.Internal.Callback
import TSK.Internal.Types


C.include "<tsk/libtsk.h>"


tskCtx :: Context
tskCtx = baseCtx {
    ctxTypesTable = (ctxTypesTable baseCtx) `M.union` tskTypesTable
  }
  where
    -- FIXME/TODO! finish adding everything that's necessary! automate??
    tskTypesTable = M.fromList [

      -- Disk image
        (TypeName "TSK_IMG_TYPE_ENUM", [t| ImgTypeEnum |])
      , (TypeName "TSK_IMG_INFO", [t| ImgInfoStruct |])


      -- Volume system
      , (TypeName "TSK_VS_TYPE_ENUM", [t| VSTypeEnum |])
      , (TypeName "TSK_VS_INFO", [t| VSInfoStruct |])
      , (TypeName "TSK_VS_PART_INFO", [t| PartInfoStruct |])
      , (TypeName "TSK_VS_PART_FLAG_ENUM", [t| PartFlags |])
      , (TypeName "TSK_VS_PART_WALK_CB", [t| PartWalkCallbackPtr |])
      , (TypeName "TSK_OFF_T", [t| Offset |]) 
      , (TypeName "TSK_DADDR_T", [t| DiskAddr |]) 
      , (TypeName "TSK_PNUM_T", [t| PartAddr |]) 
      , (TypeName "TSK_WALK_RET_ENUM", [t| CallbackRetEnum |]) 


      -- Filesystem
      , (TypeName "TSK_FS_INFO", [t| FSInfoStruct |]) 
      , (TypeName "TSK_FS_TYPE_ENUM", [t| FSTypeEnum |]) 
      , (TypeName "TSK_FS_FILE_READ_FLAG_ENUM", [t| FileReadFlags |]) 
      , (TypeName "TSK_FS_FILE_WALK_FLAG_ENUM", [t| FileWalkFlags |]) 
      , (TypeName "TSK_FS_META_ATTR_FLAG_ENUM", [t| MetaAttrFlags |]) 
      , (TypeName "TSK_FS_META_CONTENT_TYPE_ENUM", [t| MetaContentTypeEnum |]) 
      , (TypeName "TSK_FS_META_FLAG_ENUM", [t| MetaFlags |]) 
      , (TypeName "TSK_FS_META_MODE_ENUM", [t| MetaModeFlags |]) 
      , (TypeName "TSK_FS_META_TYPE_ENUM", [t| MetaFiletypeEnum |]) 
      , (TypeName "TSK_FS_NAME_FLAG_ENUM", [t| FilenameFlags |]) 
      , (TypeName "TSK_FS_NAME_TYPE_ENUM", [t| FiletypeEnum |]) 


      -- C integral types
      , (TypeName "ssize_t", [t| Int64 |]) 
      , (TypeName "uint8_t", [t| C.CUChar |]) 
      ]
