{-# LANGUAGE ForeignFunctionInterface #-}
-- Various callback types taken by tsk functions.
module TSK.Internal.Callback (
    PartWalkCallback
  , PartWalkCallbackPtr
  , wrapPartCallback
  ) where


import Foreign.Ptr
import Foreign.C.Types


import TSK.Internal.Types


type PartWalkCallback =
  Ptr VSInfoStruct -> Ptr PartInfoStruct -> Ptr () -> IO CallbackRetEnum


-- XXX/FIXME: sigh...why did tsk have to typedef as a funptr?
type PartWalkCallbackPtr = FunPtr PartWalkCallback


foreign import ccall safe "wrapper"
  mkPartCallback :: PartWalkCallback -> IO (PartWalkCallbackPtr)



wrapPartCallback :: (VSInfo -> PartInfo -> IO CallbackRetEnum)
                 -> IO (PartWalkCallbackPtr)
wrapPartCallback callback =
  mkPartCallback $
    \vsPtr partPtr _ -> callback (VSInfo vsPtr) (PartInfo partPtr)
