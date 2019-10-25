import React from 'react';
import { useCountUp } from 'react-countup';
import styled from 'styled-components'

import { useExchangeContract } from '../../hooks'
import Typography from '@material-ui/core/Typography';
import Box from '@material-ui/core/Box';

import MonetizationOn from '@material-ui/icons/MonetizationOn';

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
let stopUpdate = false;
let initialized = false;

export default function Price() {
  const contract = useExchangeContract("0x87264AB274d9DFBE81D009e46592895811127bdA")
  const { countUp, update } = useCountUp({
    start: 0,
    end: 0,
    delay: 0,
    duration: 1,
    decimals: 3,
    onReset: () => stopUpdate = true,
    //onUpdate: () => console.log('Updated!'),               
    onPauseResume: () => console.log('Paused or resumed!'),
    onStart: ({ pauseResume }) => stopUpdate = false,
    onEnd: ({ pauseResume }) => console.log("Price onEnd"),
  });

  async function updatePrice() {
    contract.ethPool().then(response => {
      let E = response
      contract.tokenPool().then(response => {
	let T = response
	let price = E*(1/(T-1))
	//console.log("E = ", parseInt(E._hex), "T = ", parseInt(T._hex))
  	if (!stopUpdate) {
          update(price)
	}
      })
    })
  }

  updatePrice()

  if (!initialized) {
    setInterval(function() {
      updatePrice()
    }, 3000);
    initialized = true;
  }

  return (
	<CustomCardContentsWrapper>
	  <Typography component="div">
            <Box fontSize="h6.fontSize" letterSpacing={6} m={1} id="title">
              <MonetizationOn /> Current Price
            </Box>
            <Box textAlign="right" fontWeight="fontWeightBold" fontSize="6vh" m={1} id="bodytext">
	      {countUp} <span id="unit">wei/W</span>
            </Box>
	  </Typography>
	</CustomCardContentsWrapper>
  );
}

