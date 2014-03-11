{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -F -pgmF htfpp #-}
-- | test access functions that can be tested
module Web.MangoPay.AccessTest where


import Web.MangoPay
import Web.MangoPay.TestUtils

import Test.Framework
import Test.HUnit (Assertion)
import Data.Aeson
import qualified Data.Text as T
import Data.Maybe (fromJust, isJust)
import Data.ByteString.Lazy as BS
import Network.HTTP.Conduit
import Data.Time.Clock.POSIX (getPOSIXTime)

-- | Take the name/email from client.conf in the current directory
-- (this file can be generated by mangopay-passphrase)
-- generates a new id/name, keeps the same email and generates a new secret
-- saves the secret to use in other tests
test_CreateCredentials :: Assertion
test_CreateCredentials=do
       js<-BS.readFile "client.conf"
       let mcred=decode js
       assertBool (isJust mcred)
       ct<-getPOSIXTime
       -- max 20 characters in ClientID
       let suff=T.take 20 $ T.pack $ show $ round ct
       let creds=(fromJust mcred)
       let newCreds=creds{cClientSecret=Nothing,
                cClientID=T.append (cClientID creds) suff,
                cName=T.append (cName creds) suff}
       creds2<-withManager (\mgr->
                runMangoPayT newCreds mgr Sandbox createCredentialsSecret)
       assertBool (isJust $ cClientSecret  creds2)       
       BS.writeFile testConfFile $ encode creds2
       -- create hooks for all event types
       mapM_ createHook [minBound .. maxBound]
