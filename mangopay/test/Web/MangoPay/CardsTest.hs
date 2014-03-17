{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -F -pgmF htfpp #-}
-- | test cards
module Web.MangoPay.CardsTest where

import Web.MangoPay
import Web.MangoPay.TestUtils

import Data.Maybe (isJust, isNothing, fromJust)
import Test.Framework
import Test.HUnit (Assertion)

import qualified Data.Text as T

-- | test a card registration
test_Card :: Assertion
test_Card = do
  us<-testMP $ listUsers (Just $ Pagination 1 1)
  assertEqual 1 (length us)
  let uid=urId $ head us
  let cr1=mkCardRegistration uid "EUR"
  cr2<-testMP $ storeCardRegistration cr1
  assertBool (isJust $ crId cr2)
  assertBool (isJust $ crCreationDate cr2)
  assertBool (isJust $ crCardRegistrationURL cr2)
  assertBool (isJust $ crAccessKey cr2)
  assertBool (isJust $ crPreregistrationData cr2)  
  assertBool (isNothing $ crRegistrationData cr2)  
  assertBool (isNothing $ crCardId cr2)  
  cr3<-testMP (\_->registerCard testCardInfo1 cr2)
  assertBool (isJust $ crRegistrationData cr3)  
  cr4<-testMP $ storeCardRegistration cr3
  assertBool (isJust $ crCardId cr4)  
  let cid=fromJust $ crCardId cr4
  c<-testMP $ fetchCard cid
  assertEqual cid $ cId c
  assertBool $ not $ T.null $ cAlias c 
  assertBool $ not $ T.null $ cCardProvider c
  assertBool $ not $ T.null $ cExpirationDate c
  assertEqual UNKNOWN $ cValidity c
  assertBool $ cActive c
  assertEqual uid $ cUserId c
  assertEqual "CB_VISA_MASTERCARD" $ cCardType c
  
 
  
  