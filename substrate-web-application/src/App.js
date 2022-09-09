import React, { createRef } from 'react'
import 'semantic-ui-css/semantic.min.css'
import {
  Sticky,
  Dimmer,
  Loader,
  Grid,
  Message,
} from 'semantic-ui-react'
import 'semantic-ui-css/semantic.min.css'

import {
  BrowserRouter,
  Routes,
  Route,
} from "react-router-dom";

import { SubstrateContextProvider, useSubstrateState } from './substrate-lib'

import Home from './Home'
import Dashboard from './Dashboard'
import AccountSelector from './AccountSelector'

function Main() {
  const { apiState, apiError, keyringState } = useSubstrateState()

  const loader = text => (
    <Dimmer active>
      <Loader size="small">{text}</Loader>
    </Dimmer>
  )

  const message = errObj => (
    <Grid centered columns={2} padded>
      <Grid.Column>
        <Message
          negative
          compact
          floating
          header="Error Connecting to Substrate"
          content={`Connection to websocket '${errObj.target.url}' failed.`}
        />
      </Grid.Column>
    </Grid>
  )

  if (apiState === 'ERROR') return message(apiError)
  else if (apiState !== 'READY') return loader('Connecting to Substrate')

  if (keyringState !== 'READY') {
    return loader(
      "Loading accounts (please review any extension's authorization)"
    )
  }

  const contextRef = createRef()

  return (
    <div ref={contextRef}>
      <BrowserRouter>
        <Sticky context={contextRef}>
          <AccountSelector />
        </Sticky>
        <Routes>
          <Route exact path="/" element={<Home />}></Route>
          <Route exact path="/dashboard" element={<Dashboard />}></Route>
        </Routes>
      </BrowserRouter>
    </div>
  )
}

export default function App() {
  return (
    <SubstrateContextProvider>
      <Main />
    </SubstrateContextProvider>
  )
}
