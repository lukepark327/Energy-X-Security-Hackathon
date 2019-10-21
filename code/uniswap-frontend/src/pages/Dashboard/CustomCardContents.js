import React, { PureComponent } from 'react';
import styled from 'styled-components'

import { makeStyles } from '@material-ui/core/styles';
import Grid from '@material-ui/core/Grid';

import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';

const CustomCardContentsWrapper = styled.div`
  #bullet {
    display: 'inline-block';
    margin: '0 2px';
    transform: 'scale(0.8)';
  }

  #title {
    fontSize: 14;
    color: ${({ theme }) => theme.doveGray}; 
  }

  #pos {
    color: ${({ theme }) => theme.doveGray}; 
    marginBottom: 12;
  }

  #bodytext {
    color: ${({ theme }) => theme.charcoalBlack};
  }

  #learnButton {
    background-color: ${({ theme }) => theme.uniswapPink};
    color: ${({ theme }) => theme.white};
  }
`

export default function CustomCardContents() {
  //const classes = useStyles();
  const bull = <span id="bullet">•</span>;
  
  return (
	<CustomCardContentsWrapper>
        <Typography id="title" gutterBottom>
          Word of the Day
        </Typography>
        <Typography variant="h5" component="h2" id="bodytext">
          be
          {bull}
          nev
          {bull}o{bull}
          lent
        </Typography>
        <Typography id="pos">
          adjective
        </Typography>
        <Typography variant="body2" component="p" id="bodytext">
          well meaning and kindly.
          <br />
          {'"a benevolent smile"'}
        </Typography>
        <CardActions>
          <Button size="small" id="learnButton">Learn More</Button>
        </CardActions>
	</CustomCardContentsWrapper>
  );
}

