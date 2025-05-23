-----------------------------------------------------------------------------
{-# LANGUAGE CPP               #-}
{-# LANGUAGE FlexibleInstances #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Miso.String
-- Copyright   :  (C) 2016-2025 David M. Johnson
-- License     :  BSD3-style (see the file LICENSE)
-- Maintainer  :  David M. Johnson <code@dmj.io>
-- Stability   :  experimental
-- Portability :  non-portable
----------------------------------------------------------------------------
module Miso.String
  ( -- ** Classes
    ToMisoString (..)
  , FromMisoString (..)
    -- ** Types
  , MisoString
    -- ** Functions
  , ms
  , fromMisoString
    -- ** Re-exports
  , module S
  ) where
----------------------------------------------------------------------------
import           Control.Exception (SomeException)
import qualified Data.ByteString         as B
import qualified Data.ByteString.Builder as B
import qualified Data.ByteString.Lazy    as BL
import           Data.JSString
import           Data.JSString.Text
import           Data.Monoid             as S
import           Data.Text               as S hiding (
#if MIN_VERSION_text(2,1,2)
  show,
#endif
#if MIN_VERSION_text(1,2,5)
  elem,
#endif
  )
import qualified Data.Text               as T
import qualified Data.Text.Encoding      as T
import qualified Data.Text.Lazy          as LT
import qualified Data.Text.Lazy.Encoding as LT
import           Text.Read(readEither)
import           Prelude                 as P
----------------------------------------------------------------------------
-- | String type swappable based on compiler
type MisoString = Text
----------------------------------------------------------------------------
-- | Convenience class for creating `MisoString` from other string-like types
class ToMisoString str where
  toMisoString :: str -> MisoString
----------------------------------------------------------------------------
-- | Class from safely parsing 'MisoString'
class FromMisoString t where
  fromMisoStringEither :: MisoString -> Either String t
----------------------------------------------------------------------------
-- | Parses a `MisoString`, throws an error when decoding
-- fails. Use `fromMisoStringEither` for as a safe alternative.
fromMisoString :: FromMisoString a => MisoString -> a
fromMisoString s =
  case fromMisoStringEither s of
    Left err -> error err
    Right x  -> x
----------------------------------------------------------------------------
-- | Convenience function, shorthand for `toMisoString`
ms :: ToMisoString str => str -> MisoString
ms = toMisoString
----------------------------------------------------------------------------
instance ToMisoString MisoString where
  toMisoString = id
----------------------------------------------------------------------------
instance ToMisoString SomeException where
  toMisoString = toMisoString . show
----------------------------------------------------------------------------
instance ToMisoString String where
  toMisoString = T.pack
----------------------------------------------------------------------------
instance ToMisoString LT.Text where
  toMisoString = LT.toStrict
----------------------------------------------------------------------------
instance ToMisoString JSString where
  toMisoString = textFromJSString
----------------------------------------------------------------------------
instance ToMisoString B.ByteString where
  toMisoString = toMisoString . T.decodeUtf8
----------------------------------------------------------------------------
instance ToMisoString BL.ByteString where
  toMisoString = toMisoString . LT.decodeUtf8
----------------------------------------------------------------------------
instance ToMisoString B.Builder where
  toMisoString = toMisoString . B.toLazyByteString
----------------------------------------------------------------------------
instance ToMisoString Float where
  toMisoString = T.pack . P.show
----------------------------------------------------------------------------
instance ToMisoString Double where
  toMisoString = T.pack . P.show
----------------------------------------------------------------------------
instance ToMisoString Int where
  toMisoString = T.pack . P.show
----------------------------------------------------------------------------
instance ToMisoString Word where
  toMisoString = T.pack . P.show
----------------------------------------------------------------------------
instance FromMisoString MisoString where
  fromMisoStringEither = Right
----------------------------------------------------------------------------
instance FromMisoString String where
  fromMisoStringEither = Right . T.unpack
----------------------------------------------------------------------------
instance FromMisoString LT.Text where
  fromMisoStringEither = Right . LT.fromStrict
----------------------------------------------------------------------------
instance FromMisoString JSString where
  fromMisoStringEither = Right . textToJSString
----------------------------------------------------------------------------
instance FromMisoString B.ByteString where
  fromMisoStringEither = fmap T.encodeUtf8 . fromMisoStringEither
----------------------------------------------------------------------------
instance FromMisoString BL.ByteString where
  fromMisoStringEither = fmap LT.encodeUtf8 . fromMisoStringEither
----------------------------------------------------------------------------
instance FromMisoString B.Builder where
  fromMisoStringEither = fmap B.byteString . fromMisoStringEither
----------------------------------------------------------------------------
instance FromMisoString Float where
  fromMisoStringEither = readEither . T.unpack
----------------------------------------------------------------------------
instance FromMisoString Double where
  fromMisoStringEither = readEither . T.unpack
----------------------------------------------------------------------------
instance FromMisoString Int where
  fromMisoStringEither = readEither . T.unpack
----------------------------------------------------------------------------
instance FromMisoString Word where
  fromMisoStringEither = readEither . T.unpack
----------------------------------------------------------------------------
