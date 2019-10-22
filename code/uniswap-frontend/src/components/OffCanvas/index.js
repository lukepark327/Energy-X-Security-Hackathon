import React from 'react'
import styled from 'styled-components'
import { Link } from 'react-router-dom';
import MenuIcon from '@material-ui/icons/Menu';

import { makeStyles } from '@material-ui/core/styles';
import Drawer from '@material-ui/core/Drawer';
import List from '@material-ui/core/List';
import Divider from '@material-ui/core/Divider';
import ListItem from '@material-ui/core/ListItem';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemText from '@material-ui/core/ListItemText';

import Dashboard from '@material-ui/icons/Dashboard';
import Settings from '@material-ui/icons/Settings';
import SwapHoriz from '@material-ui/icons/SwapHoriz';

const useStyles = makeStyles({
  list: {
    width: 250,
  },
});

const MenuIconWrapper = styled.div`
  cursor: pointer;               
`

export default function OffCanvas() {
  const classes = useStyles();
  const [state, setState] = React.useState({
    top: false,
    left: false,
    bottom: false,
    right: false,
  });

  const toggleDrawer = (side, open) => event => {
    if (event.type === 'keydown' && (event.key === 'Tab' || event.key === 'Shift')) {
      return;
    }

    setState({ ...state, [side]: open });
  };

  const sideList = side => (
    <div
      className={classes.list}
      role="presentation"
      onClick={toggleDrawer(side, false)}
      onKeyDown={toggleDrawer(side, false)}
    >
      <List>
        {['Dashboard', 'Uniswap'].map((text, index) => (
	  <Link key={text} to={'./' + text} style={{ color: 'inherit', textDecoration: 'none' }}>
          <ListItem button key={text}>
            <ListItemIcon>{index % 2 === 0 ? <Dashboard /> : <SwapHoriz />}</ListItemIcon>
            <ListItemText primary={text} />
          </ListItem>
	  </Link>
        ))}
      </List>
      <Divider />
      <List>
        {['Settings'].map((text, index) => (
          <ListItem button key={text}>
            <ListItemIcon>{index % 2 === 0 ? <Settings /> : <Settings />}</ListItemIcon>
            <ListItemText primary={text} />
          </ListItem>
        ))}
      </List>
    </div>
  );

  return (
    <div>
      <MenuIconWrapper onClick={toggleDrawer('left', true)}>
        <MenuIcon />
      </MenuIconWrapper>
      <Drawer open={state.left} onClose={toggleDrawer('left', false)}>
        {sideList('left')}
      </Drawer>
    </div>
  )
}
