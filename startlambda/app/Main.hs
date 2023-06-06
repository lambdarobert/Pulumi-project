{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE LambdaCase #-}

module Main where

import Prelude hiding (lookup)
import AWS.Lambda.Runtime
import Data.Aeson
import Data.Aeson.KeyMap
import Data.ByteString.Lazy.Internal
import Data.Text
import Data.Scientific
import Data.Maybe (fromJust)
import System.Environment (getEnv)
import Network.HTTP.Client hiding (path)
import Network.HTTP.Client.TLS
import Network.HTTP.Types.Status
import Data.String.Interpolate ( i )
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

postRequest :: String -> ByteString -> ByteString -> Manager -> IO (Response ByteString)
postRequest url body contentType manager = do
  initialRequest <- parseRequest url
  let request = initialRequest {method = "POST", requestBody = RequestBodyLBS body, requestHeaders = [("Content-Type", [i|#{contentType}|])]} 
  response <- httpLbs request manager
  return response

handler :: Object -> IO (Either String Value)
handler input = do
  manager <- newManager tlsManagerSettings
  print input
  token <- getEnv "HCAPTCHA"
  ec2Auth <- getEnv "AUTHORIZATION"
  ec2Url <- getEnv "EC2URL"
  let lambdaReq = createInput input
  captchaResults <- postRequest "https://hcaptcha.com/siteverify" [i|secret=#{token}&response=#{body lambdaReq}|] "application/x-www-form-urlencoded" manager 
  case statusCode $ responseStatus captchaResults of
    200 -> do
      let body = fromJust $ (decode $ responseBody captchaResults :: Maybe Object)
      let hcaptchaResult = extractBool "success" body 
      if hcaptchaResult then do
                        ec2Response <- postRequest ec2Url [i|#{ec2Auth}|] "text/plain" manager
                        case statusCode $ responseStatus ec2Response of
                          400 -> return $ Right $ createOutput 503 [i|#{responseBody ec2Response}|]
                          200 -> return $ Right $ createOutput 200 "The server is now starting. It should be ready soon."
                          _ -> return $ Right $ createOutput 503 [i|This error should also not appear. error #{show $ responseStatus $ ec2Response}|]

      else return $ Right $ createOutput 403 ([i|Verification failed.|])

    _ -> return $ Right $ createOutput 503 "CAPTCHA server is not working."

main :: IO ()
main = ioRuntime handler

--main :: IO ()
--main = ioRuntime (\(obj :: Value) -> return $ Right $ (createOutput 200 [i|#{encode obj}|]))
