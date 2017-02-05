{-# LANGUAGE OverloadedStrings #-}

module Debiania.Compilers (
    gzip
  , gzipFileCompiler
  , debianiaCompiler
) where

import Data.Monoid ((<>))
import Data.String.Utils (split)
import Text.Pandoc.Options (WriterOptions(writerHTMLMathMethod),
    HTMLMathMethod(MathJax))

import qualified Data.ByteString.Lazy as LBS
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE

import Hakyll

-- | Essentially a @pandocCompiler@, but with some preprocessing:
--
-- * @$break$@ on a separate line will be replaced by a section break image.
debianiaCompiler :: Compiler (Item String)
debianiaCompiler =
      getResourceBody
  >>= withItemBody (go . split "\n\n$break$\n\n")
  >>= renderPandocWith
        defaultHakyllReaderOptions
        -- The empty string is path to mathjax.js. We don't want Pandoc to
        -- embed it in output for us as we already do that in Hakyll templates.
        (defaultHakyllWriterOptions { writerHTMLMathMethod = MathJax "" })

  where
  go :: [String] -> Compiler String
  go [] = return ""
  go [single] = return single
  go (before:after:rest) = do
    emptyItem <- makeItem ("" :: String)
    newItem <- loadAndApplyTemplate
                 "templates/break.html"
                 (constField "before" before <> constField "after" after)
                 emptyItem
    let newBody = itemBody newItem
    go (newBody:rest)

gzip :: Item String -> Compiler (Item LBS.ByteString)
gzip = withItemBody
         (unixFilterLBS
           "7z"
           [ "a"      -- create archive
           , "dummy"  -- archive's filename (won't be used)
           , "-tgzip" -- archive format
           , "-mx9"   -- m-m-maximum compression
           , "-si"    -- read data from stdin
           , "-so"    -- write archive to stdout
           ]
         . LBS.fromStrict
         . TE.encodeUtf8
         . T.pack)

gzipFileCompiler :: Compiler (Item LBS.ByteString)
gzipFileCompiler = do identifier <- getUnderlying
                      body <- loadBody (setVersion Nothing identifier)
                      makeItem body
                        >>= gzip