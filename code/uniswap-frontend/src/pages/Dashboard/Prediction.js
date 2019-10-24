import React from 'react';
import styled from 'styled-components'

import { useWeb3Context } from 'web3-react'
import { useFactoryContract } from '../../hooks'
import { useTransactionAdder } from '../../contexts/Transactions'

import Typography from '@material-ui/core/Typography';
import Box from '@material-ui/core/Box';

import OfflineBolt from '@material-ui/icons/OfflineBolt';

const CustomCardContentsWrapper = styled.div`
  #title {
    color: ${({ theme }) => theme.charcoalBlack};
    height: 17vh;
  }

  #bodytext {
    color: ${({ theme }) => theme.doveGray}; 
  }

  #learnButton {
    background-color: ${({ theme }) => theme.uniswapPink};
    color: ${({ theme }) => theme.white};
  }

  #unit { 
    font-size: 2.5vh;
    font-weight: normal;
  }
`

let initialized = false;

export default function Prediction() {
  const { account } = useWeb3Context()
  const factory = useFactoryContract()
  const addTransaction = useTransactionAdder()
  let reqTime = 0;

  function animateValue(id, start, end, duration) {
    // assumes integer values for start and end
    
    var obj = document.getElementById(id);
    var range = end - start;
    // no timer shorter than 50ms (not really visible any way)
    var minTimer = 50;
    // calc step time to show all interediate values
    var stepTime = Math.abs(Math.floor(duration / range));
    
    // never go below minTimer
    stepTime = Math.max(stepTime, minTimer);
    
    // get current time and calculate desired end time
    var startTime = new Date().getTime();
    var endTime = startTime + duration;
    var timer;
  
    function run() {
        var now = new Date().getTime();
        var remaining = Math.max((endTime - now) / duration, 0);
        var value = Math.round(end - (remaining * range));
        obj.innerHTML = value;
        if (value == end) {
            clearInterval(timer);
        }
    }
    
    timer = setInterval(run, stepTime);
    run();
  }

  async function requestInference() {      
    // args : int _reqTime, int[] memory _infos
    reqTime = Math.round((new Date()).getTime()/1000)
    console.log("REQUEST INFERENCE! @", reqTime)
    let args = [reqTime, [1,1,1]]
    factory.requestInference(...args, { gasLimit: 750000 }).then(response => {
      addTransaction(response)
    })
  }

  async function getResponse() {
    // args : reqADDRESS + reqTime
    console.log("GET RESPONSE! @", account + reqTime)
    let args = [account + reqTime]
    factory.getResponse(...args).then(response => {
      console.log(response)
      document.getElementById("predictedValue").innerHTML = response;
    })
  }

  async function updateResponse(time) {
    if (document.getElementById("predictedValue") && document.getElementById("priceValue")) {
      // args : reqADDRESS + reqTime
      console.log("GET LAST RESPONSE!")
      factory.latestPredictedPower().then(response => {
        animateValue("predictedValue", parseInt(document.getElementById("predictedValue").innerHTML), response, time);
        animateValue("priceValue", parseInt(document.getElementById("priceValue").innerHTML), (response+100)/2, time);
      })
    }
  }

  function initializeValue() {
    console.log("INIT")
    updateResponse(2000)
  }

  // Initialize event
  if (!initialized) {
    setTimeout(function() {
      initializeValue()
    }, 100);

    // Update every 5sec
    setInterval(function() {
      updateResponse(500)
    }, 5000);

    initialized = true;
  }

  return (
	<CustomCardContentsWrapper>
	  <Typography component="div">
            <Box fontSize="h6.fontSize" letterSpacing={6} m={1} id="title">
              <OfflineBolt onClick={requestInference}/> Prediction Result
            </Box>
            <Box textAlign="right" fontWeight="fontWeightBold" fontSize="6vh" m={1} id="bodytext">
              <span id="predictedValue">999</span> <span id="unit">MW</span>
            </Box>
	  </Typography>
	</CustomCardContentsWrapper>
  );
}

