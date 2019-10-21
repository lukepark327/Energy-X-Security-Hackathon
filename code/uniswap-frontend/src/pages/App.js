import React, { Suspense, lazy } from 'react'
import styled from 'styled-components'
import { BrowserRouter, Redirect, Route, Switch } from 'react-router-dom'

import Web3ReactManager from '../components/Web3ReactManager'
import Header from '../components/Header'
import Footer from '../components/Footer'

import NavigationTabs from '../components/NavigationTabs'
import { isAddress, getAllQueryParams } from '../utils'

const Uniswap = lazy(() => import('./Uniswap'))
const Dashboard = lazy(() => import('./Dashboard'))

const AppWrapper = styled.div`
  display: flex;
  flex-flow: column;
  align-items: flex-start;
  height: 100vh;
`

const HeaderWrapper = styled.div`
  ${({ theme }) => theme.flexRowNoWrap}
  width: 100%;
  justify-content: space-between;
  align-items: center;
`
const FooterWrapper = styled.div`
  width: 100%;
  min-height: 30px;
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
`

const Body = styled.div`
  max-width: 35rem;
  width: 90%;
  /* margin: 0 1.25rem 1.25rem 1.25rem; */
`

export default function App() {
  const params = getAllQueryParams()
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
	      <div>
	        <Route exact path="/" component={Dashboard} />
	        <Route exact path="/Dashboard" component={Dashboard} />
	        <Route exact path="/Uniswap" component={Uniswap} />
	      </div>
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
