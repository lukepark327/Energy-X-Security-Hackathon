import React from 'react';
import styled from 'styled-components'

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

export default function Price() {
  return (
	<CustomCardContentsWrapper>
	  <Typography component="div">
            <Box fontSize="h6.fontSize" letterSpacing={6} m={1} id="title">
              <MonetizationOn /> Current Price
            </Box>
            <Box textAlign="right" fontWeight="fontWeightBold" fontSize="6vh" m={1} id="bodytext">
              <span id="priceValue">0</span> <span id="unit">EPT/W</span>
            </Box>
	  </Typography>
	</CustomCardContentsWrapper>
  );
}

