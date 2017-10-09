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


import TSK.Internal.Types


C.include "<tsk/libtsk.h>"


tskCtx :: Context
tskCtx = baseCtx {
    ctxTypesTable = (ctxTypesTable baseCtx) `M.union` tskTypesTable
  }
  where
    -- FIXME/TODO! finish adding everything that's necessary! automate??
    tskTypesTable = M.fromList [
        (TypeName "TSK_IMG_TYPE_ENUM", [t| ImgTypeEnum |])
      , (TypeName "TSK_IMG_INFO", [t| ImgInfoStruct |])
      , (TypeName "TSK_OFF_T", [t| Offset |]) 
      , (TypeName "ssize_t", [t| Int64 |]) 
      ]
