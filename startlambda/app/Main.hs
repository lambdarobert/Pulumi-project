{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Prelude hiding (lookup)
import AWS.Lambda.Runtime
import Data.Aeson
import Data.Aeson.KeyMap
import Data.ByteString.Lazy.Internal
import Data.Aeson.KeyMap
import Data.Text
import Data.Scientific
import Data.Maybe (fromJust)

data LambdaRequest = LambdaRequest {
                        resource :: Text,
                        path :: Text,
                        httpMethod :: Text,
                        body :: Text,
                        ip :: Text
                     }

lookupUnsafe :: Key -> KeyMap v -> v
lookupUnsafe k kmap = fromJust $ lookup k kmap

-- UNSAFE
extractString :: Key -> KeyMap Value -> Text
extractString k kmap = case lookupUnsafe k kmap of
                        String txt -> txt
-- UNSAFE
extractObject :: Key -> KeyMap Value -> Object
extractObject k kmap = case lookupUnsafe k kmap of
                         Object obj -> obj

-- UNSAFE
-- but if this function fails, this means AWS failed us...
createInput :: ByteString -> LambdaRequest
createInput input = let omap = fromJust $ decode input :: Object in
                        LambdaRequest {
                                        resource = "resource" `extractString` omap,
                                        path = "path" `extractString` omap,
                                        httpMethod = "httpMethod" `extractString` omap,
                                        body = "body" `extractString` omap,
                                        ip = "X-Forwarded-For" `extractString` ("headers" `extractObject` omap) 
                                      }

-- translate output into JSON
createOutput :: Scientific -> Text -> Value
createOutput statusCode msg = Object $ fromList [
                                                  ("statusCode", Number statusCode),
                                                  ("headers", Object $ fromList [("Content-Type", String "text/plain")]),
                                                  ("body", String msg)
                                                ]
handler :: Value -> Value
handler _ = createOutput 200 "it works"

main :: IO ()
main = pureRuntime handler
