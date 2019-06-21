module Dotenv.Internal.FileSystem where

import Prelude
import Data.Symbol (SProxy(..))
import Effect.Aff (Aff)
import Node.Encoding (Encoding)
import Node.FS.Aff (readTextFile) as FS
import Run (FProxy, Run, lift)

type FILE_SYSTEM = FProxy (FileSystemF)

data FileSystemF a = ReadTextFile Encoding String (String -> a)

derive instance functorFileSystemF :: Functor FileSystemF

_fileSystem = SProxy :: SProxy "fileSystem"

handleFileSystem :: FileSystemF ~> Aff
handleFileSystem (ReadTextFile encoding filePath callback) = FS.readTextFile encoding filePath >>= callback >>> pure

readTextFile :: forall r. Encoding -> String -> Run (fileSystem :: FILE_SYSTEM | r) String
readTextFile encoding filePath = lift _fileSystem (ReadTextFile encoding filePath identity)
