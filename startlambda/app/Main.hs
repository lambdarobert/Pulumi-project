{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

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
import System.Environment (getEnv)
import Network.HTTP.Client hiding (path)
import Network.HTTP.Client.TLS
import Network.HTTP.Types.Status
import Data.String.Interpolate ( i )
import GHC.IO.FD (stderr)
import System.IO (hPutStrLn, stderr)

data LambdaRequest = LambdaRequest {
                        body :: Text
                                   }

lookupUnsafe :: Key -> KeyMap v -> v
lookupUnsafe k kmap = fromJust $ lookup k kmap

-- UNSAFE
extractString :: Key -> KeyMap Value -> Text
extractString k kmap = case lookupUnsafe k kmap of
                         String txt -> txt
                         _ -> "NULL"
--UNSAFE
extractBool :: Key -> KeyMap Value -> Bool
extractBool k kmap = case lookupUnsafe k kmap of
                       Bool b -> b

-- UNSAFE
extractObject :: Key -> KeyMap Value -> Object
extractObject k kmap = case lookupUnsafe k kmap of
                         Object obj -> obj

-- UNSAFE
-- but if this function fails, this means AWS failed us...
createInput :: Object -> LambdaRequest
createInput omap = LambdaRequest { 
                                    body = "body" `extractString` omap  
                                  }

-- translate output into JSON
createOutput :: Scientific -> Text -> Value
createOutput statusCode msg = Object $ fromList [
                                                  ("statusCode", Number statusCode),
                                                  ("headers", Object $ fromList [("Content-Type", String "text/plain")]),
                                                  ("body", String msg)
                                                ]

postRequest :: String -> ByteString -> Manager -> IO (Response ByteString)
postRequest url body manager = do
  initialRequest <- parseRequest url
  let request = initialRequest {method = "POST", requestBody = RequestBodyLBS body, requestHeaders = [("Content-Type", "application/x-www-form-urlencoded")]} 
  response <- httpLbs request manager
  return response

handler :: Object -> IO (Either String Value)
handler input = do
  manager <- newManager tlsManagerSettings
  print input
  token <- getEnv "HCAPTCHA"
  let lambdaReq = createInput input
  hPutStrLn System.IO.stderr [i|We are sending the following to hcaptcha: secret=#{token}&response=#{body lambdaReq}|] 
  captchaResults <- postRequest "https://hcaptcha.com/siteverify" [i|secret=#{token}&response=#{body lambdaReq}|] manager 
  case statusCode $ responseStatus captchaResults of
    200 -> do
      let body = fromJust $ (decode $ responseBody captchaResults :: Maybe Object)
      let hcaptchaResult = extractBool "success" body 
      if hcaptchaResult then do
                        return $ Right $ createOutput 200 "Verification passed."
      else return $ Right $ createOutput 403 ([i|Verification failed.|])

    _ -> return $ Right $ createOutput 503 "CAPTCHA server is not working."

main :: IO ()
main = ioRuntime handler

--main :: IO ()
--main = ioRuntime (\(obj :: Value) -> return $ Right $ (createOutput 200 [i|#{encode obj}|]))
