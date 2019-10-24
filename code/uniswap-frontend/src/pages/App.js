import React, { Suspense, lazy } from 'react'
import styled from 'styled-components'
import { BrowserRouter, Route, Switch } from 'react-router-dom'

import Header from '../components/Header'
import Footer from '../components/Footer'

const Uniswap = lazy(() => import('./Uniswap'))
const Dashboard = lazy(() => import('./Dashboard'))

const AppWrapper = styled.div`
  display: flex;
  flex-flow: column;
  align-items: flex-start;
  height: 100%;
`

const HeaderWrapper = styled.div`
  ${({ theme }) => theme.flexRowNoWrap}
  width: 100%;
  height: 100px;
  justify-content: space-between;
  align-items: center;
`
const FooterWrapper = styled.div`
  width: 100%;
  height: 60px;
  align-self: flex-end;
`

const BodyWrapper = styled.div`
  display: flex;
  flex-direction: column;
  width: 100%;
  justify-content: flex-start;
  align-items: center;
  flex: 1;
  overflow: auto;
  height: calc(100% - 160px);
`

const Body = styled.div`
  width: 90%;
  align-items: center;
`

export default function App() {
  return (
    <>
    <BrowserRouter>
      <Suspense fallback={null}>
        <AppWrapper>
          <HeaderWrapper>
            <Header />
          </HeaderWrapper>
          <BodyWrapper>
            <Body>
	      <Switch>
	        <Route exact path="/" component={Dashboard} />
	        <Route exact path="/Dashboard" component={Dashboard} />
	        <Route exact path="/Uniswap" component={Uniswap} />
	        <Route exact path="/swap" component={Uniswap} />
	        <Route exact path="/send" component={Uniswap} />
	        <Route exact path="/add-liquidity" component={Uniswap} />
	      </Switch>
            </Body>
          </BodyWrapper>
          <FooterWrapper>
            <Footer />
          </FooterWrapper>
        </AppWrapper>
      </Suspense>
    </BrowserRouter>
    </>
  )
}
